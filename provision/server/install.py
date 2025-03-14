#!/usr/bin/env python3

import argparse
import logging
import subprocess
import sys
from pathlib import Path
import os
import re
import time

import jinja2

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger(__name__)

TEMPLATE_DIR = Path(__file__).parent.absolute() / "templates"


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Install and configure Puppet Server 8 on Ubuntu")
    parser.add_argument("--java-heap", type=str, default="2g", help="Java heap size for Puppet Server (default: 2g)")
    parser.add_argument("--certname", type=str, help="Certificate name for Puppet Server (default: system FQDN)")
    parser.add_argument("--password", type=str, required=True, help="Password for Puppet repository authentication")
    parser.add_argument("--puppet-src", type=str, help="Source directory to copy Puppet structure from")
    return parser.parse_args()


def check_root():
    if os.geteuid() != 0:
        logger.error("This script must be run as root")
        sys.exit(1)


def render_template(template_file: str, context: dict) -> str:
    template_path = TEMPLATE_DIR / template_file

    if not template_path.exists():
        logger.error(f"Template file not found: {template_path}")
        sys.exit(1)

    template = jinja2.Template(template_path.read_text())
    return template.render(**context)


def is_puppet_repo_installed() -> bool:
    repo_paths = [Path("/etc/apt/sources.list.d/puppet.list"), Path("/etc/apt/sources.list.d/puppet8.list")]
    return any(path.exists() for path in repo_paths) or list(Path("/etc/apt/sources.list.d").glob("puppet*.list"))


def is_puppetserver_installed() -> bool:
    try:
        result = subprocess.run(
            ["dpkg", "-l", "puppetserver"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False
        )
        return result.returncode == 0 and "ii" in result.stdout.decode("utf-8")
    except:
        return False


def is_puppet_auth_configured(password: str) -> bool:
    auth_file_path = Path("/etc/apt/auth.conf.d/apt-puppetcore-puppet.conf")

    if not auth_file_path.exists():
        return False

    content = auth_file_path.read_text()
    if f"password {password}" not in content:
        return False

    return True


def is_puppet_configured(certname: str) -> bool:
    puppet_conf_path = Path("/etc/puppetlabs/puppet/puppet.conf")
    if not puppet_conf_path.exists():
        return False

    try:
        content = puppet_conf_path.read_text()
        if certname and f"certname = {certname}" in content:
            return True
        elif not certname and "certname = " in content:
            return True
    except:
        pass

    return False


def is_puppetserver_running() -> bool:
    try:
        result = subprocess.run(
            ["systemctl", "status", "puppetserver"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False
        )
        return result.returncode == 0 and "active (running)" in result.stdout.decode("utf-8")
    except:
        return False


def update_packages():
    subprocess.run(["apt-get", "update"], check=True)


def install_dependencies():
    subprocess.run(["apt-get", "install", "-y", "wget"], check=True)


def get_ubuntu_release() -> str:
    return subprocess.run(["lsb_release", "-cs"], capture_output=True, text=True).stdout.strip()


def download_puppet_release(release: str):
    logger.info("Downloading Puppet release package")
    subprocess.run(
        ["wget", "--content-disposition", f"https://apt-puppetcore.puppet.com/public/puppet8-release-{release}.deb"],
        check=True,
    )


def install_deb_package(package_path: str):
    logger.info(f"Installing {package_path}")
    subprocess.run(["dpkg", "-i", package_path], check=True)


def setup_auth_conf(password: str):
    auth_dir = Path("/etc/apt/auth.conf.d")
    auth_dir.mkdir(parents=True, exist_ok=True)

    auth_file = auth_dir / "apt-puppetcore-puppet.conf"
    auth_content = render_template("apt-puppetcore-puppet.conf.j2", {"password": password})
    auth_file.write_text(auth_content)
    auth_file.chmod(0o600)


def cleanup_deb_files():
    for deb_file in Path().glob("puppet8-release-*.deb"):
        deb_file.unlink()


def install_puppet_repo(password: str):
    if is_puppet_repo_installed():
        logger.info("Puppet repository is already installed. Skipping.")
        return

    logger.info("Installing Puppet 8 repository for Ubuntu")

    update_packages()
    install_dependencies()

    release = get_ubuntu_release()
    download_puppet_release(release)
    install_deb_package(f"puppet8-release-{release}.deb")

    if not is_puppet_auth_configured(password):
        setup_auth_conf(password)
    else:
        logger.info("Authentication is already configured. Skipping.")

    update_packages()
    logger.info("Puppet repository installed successfully")

    cleanup_deb_files()


def install_puppet_server():
    if is_puppetserver_installed():
        logger.info("Puppet Server is already installed. Skipping.")
        return

    logger.info("Installing Puppet Server")
    subprocess.run(["apt-get", "install", "-y", "puppetserver"], check=True)
    logger.info("Puppet Server installed successfully")


def get_system_certname() -> str:
    return subprocess.run(["hostname", "-f"], capture_output=True, text=True).stdout.strip()


def get_server_ip():
    try:
        result = subprocess.run(["ip", "route", "get", "8.8.8.8"], capture_output=True, text=True, check=True)
        match = re.search(r"src\s+(\d+\.\d+\.\d+\.\d+)", result.stdout)
        if match:
            return match.group(1)
        else:
            logger.error("Could not find IP address in route output")
            sys.exit(1)
    except Exception as e:
        logger.error(f"Could not auto-detect server IP: {e}")
        sys.exit(1)


def is_hosts_entry_exists(hostname: str, server_ip: str) -> bool:
    hosts_path = Path("/etc/hosts")

    if not hosts_path.exists():
        return False

    try:
        content = hosts_path.read_text()
        pattern = re.compile(rf"^(?:\S+)(?:\s+)(?:.+\s+)?{re.escape(hostname)}(?:\s+.*)?$", re.MULTILINE)
        matches = pattern.findall(content)

        if not matches:
            return False

        for match in matches:
            if match.split()[0] == server_ip:
                return True

        return False
    except Exception as e:
        logger.error(f"Error checking hosts file: {e}")
        return False


def add_hosts_entry(hostname: str, server_ip: str) -> bool:
    if not hostname or not server_ip:
        logger.warning("Cannot add hosts entry: missing hostname or IP")
        return False

    hosts_path = Path("/etc/hosts")

    if is_hosts_entry_exists(hostname, server_ip):
        logger.info(f"Hosts entry for {hostname} ({server_ip}) already exists. Skipping.")
        return True

    try:
        with open(hosts_path, "a") as f:
            f.write(f"\n{server_ip}    {hostname}    # Added by Puppet Server installer\n")
        logger.info(f"Added hosts entry: {server_ip} -> {hostname}")
        return True
    except Exception as e:
        logger.error(f"Error adding hosts entry: {e}")
        return False


def set_java_heap_size(heap_size: str):
    default_file = Path("/etc/default/puppetserver")
    if default_file.exists():
        content = default_file.read_text()
        if "JAVA_ARGS=" in content:
            new_content = content.replace("-Xms2g -Xmx2g", f"-Xms{heap_size} -Xmx{heap_size}")
            default_file.write_text(new_content)
            logger.info(f"Set Java heap size to {heap_size}")


def create_puppet_conf(certname: str):
    puppet_conf_dir = Path("/etc/puppetlabs/puppet")
    puppet_conf_dir.mkdir(parents=True, exist_ok=True)

    puppet_conf_content = render_template("puppet.conf.j2", {"certname": certname})
    puppet_conf_file = puppet_conf_dir / "puppet.conf"
    puppet_conf_file.write_text(puppet_conf_content)
    logger.info(f"Created puppet.conf with certname '{certname}'")


def copy_puppet_structure(source_dir: Path):
    if not source_dir or not source_dir.exists():
        logger.error(f"Source directory does not exist: {source_dir}")
        sys.exit(1)

    env_dir = Path("/etc/puppetlabs/code")
    env_dir.mkdir(parents=True, exist_ok=True)

    logger.info(f"Syncing Puppet structure from {source_dir} to {env_dir}")
    subprocess.run(["rsync", "-a", "--delete", source_dir, env_dir], check=True)
    logger.info("Puppet structure synced successfully")


def configure_puppet_server(args: argparse.Namespace) -> str:
    certname = args.certname if args.certname else get_system_certname()

    server_ip = get_server_ip()
    logger.info(f"Adding self DNS configuration with IP {server_ip}")
    if not add_hosts_entry(certname, server_ip):
        logger.error("Failed to add hosts entry. Exiting.")
        sys.exit(1)

    if is_puppet_configured(certname):
        logger.info(f"Puppet Server is already configured with certname '{certname}'. Skipping.")
    else:
        logger.info("Configuring Puppet Server")
        set_java_heap_size(args.java_heap)
        create_puppet_conf(certname)

    if args.puppet_src:
        copy_puppet_structure(Path(args.puppet_src))
    else:
        logger.info("No puppet source specified. Skipping environment setup.")

    logger.info("Puppet Server configured successfully")
    return certname


def start_puppet_server():
    subprocess.run(["systemctl", "enable", "puppetserver"], check=True)

    if is_puppetserver_running():
        logger.info("Puppet Server is already running. Skipping.")
        return

    logger.info("Starting Puppet Server")
    subprocess.run(["systemctl", "start", "puppetserver"], check=True)

    if is_puppetserver_running():
        logger.info("Puppet Server is now running")
    else:
        logger.error("Failed to start Puppet Server. Check logs for details.")
        sys.exit(1)


def restart_puppet_server():
    logger.info("Restarting Puppet Server")
    subprocess.run(["systemctl", "restart", "puppetserver"], check=True)
    logger.info("Puppet Server restarted")


def check_templates():
    required_templates = ["apt-puppetcore-puppet.conf.j2", "puppet.conf.j2", "routes.yaml.j2"]

    missing_templates = [template for template in required_templates if not (TEMPLATE_DIR / template).exists()]

    if missing_templates:
        logger.error(f"Missing required template files: {', '.join(missing_templates)}")
        logger.error("Please make sure all template files are in the same directory as this script")
        sys.exit(1)


def main():
    args = parse_arguments()
    logger.info("Starting Puppet Server installation")

    check_root()
    check_templates()

    try:
        install_puppet_repo(args.password)
        install_puppet_server()

        certname = configure_puppet_server(args)
        server_ip = get_server_ip()

        start_puppet_server()

        logger.info("Puppet Server installation completed successfully")
        logger.info(f"Puppet Server is running with certificate name: {certname}")
        logger.info(f"Server IP address: {server_ip}")
        logger.info(f"Hosts entry added: {server_ip} -> {certname}")
        logger.info("You can now connect agents to this server")

    except subprocess.CalledProcessError as e:
        logger.error(f"Error executing command: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
