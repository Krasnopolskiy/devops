#!/usr/bin/env python3

import argparse
import logging
import subprocess
import sys
from pathlib import Path
import os
import re

import jinja2

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger(__name__)

TEMPLATE_DIR = Path(__file__).parent.absolute() / "templates"


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Install and configure Puppet Agent 8 on Ubuntu")
    parser.add_argument("--certname", type=str, help="Certificate name for Puppet Agent (default: system FQDN)")
    parser.add_argument("--server", type=str, required=True, help="Puppet Server hostname or IP address")
    parser.add_argument("--server-ip", type=str, help="IP address of the Puppet Server to add to hosts file")
    parser.add_argument("--password", type=str, required=True, help="Password for Puppet repository authentication")
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


def is_puppet_agent_installed() -> bool:
    try:
        result = subprocess.run(
            ["dpkg", "-l", "puppet-agent"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False
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


def is_puppet_configured(certname: str, server: str) -> bool:
    puppet_conf_path = Path("/etc/puppetlabs/puppet/puppet.conf")
    if not puppet_conf_path.exists():
        return False

    try:
        content = puppet_conf_path.read_text()
        has_certname = True if not certname else f"certname = {certname}" in content
        has_server = f"server = {server}" in content
        return has_certname and has_server
    except:
        pass

    return False


def is_hosts_entry_exists(server: str, server_ip: str) -> bool:
    hosts_path = Path("/etc/hosts")

    if not hosts_path.exists():
        return False

    try:
        content = hosts_path.read_text()
        pattern = re.compile(rf"^(?:\S+)(?:\s+)(?:.+\s+)?{re.escape(server)}(?:\s+.*)?$", re.MULTILINE)
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


def add_hosts_entry(server: str, server_ip: str) -> bool:
    hosts_path = Path("/etc/hosts")

    if is_hosts_entry_exists(server, server_ip):
        logger.info(f"Hosts entry for {server} ({server_ip}) already exists. Skipping.")
        return True

    try:
        with open(hosts_path, "a") as f:
            f.write(f"\n{server_ip}    {server}    # Added by Puppet Agent installer\n")
        logger.info(f"Added hosts entry: {server_ip} -> {server}")
        return True
    except Exception as e:
        logger.error(f"Error adding hosts entry: {e}")
        return False


def update_packages():
    subprocess.run(["apt-get", "update"], check=True)


def install_dependencies():
    subprocess.run(["apt-get", "install", "-y", "wget", "curl"], check=True)


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


def install_puppet_agent():
    if is_puppet_agent_installed():
        logger.info("Puppet Agent is already installed. Skipping.")
        return

    logger.info("Installing Puppet Agent")
    subprocess.run(["apt-get", "install", "-y", "puppet-agent"], check=True)
    logger.info("Puppet Agent installed successfully")


def get_system_certname() -> str:
    return subprocess.run(["hostname", "-f"], capture_output=True, text=True).stdout.strip()


def create_puppet_conf(certname: str, server: str):
    puppet_conf_dir = Path("/etc/puppetlabs/puppet")
    puppet_conf_dir.mkdir(parents=True, exist_ok=True)

    puppet_conf_content = render_template(
        "puppet-agent.conf.j2",
        {
            "certname": certname,
            "server": server,
        },
    )
    puppet_conf_file = puppet_conf_dir / "puppet.conf"
    puppet_conf_file.write_text(puppet_conf_content)
    logger.info(f"Created puppet.conf with certname '{certname}' and server '{server}'")


def configure_puppet_agent(args: argparse.Namespace) -> str:
    certname = args.certname if args.certname else get_system_certname()

    if is_puppet_configured(certname, args.server):
        logger.info(
            f"Puppet Agent is already configured with certname '{certname}' and server '{args.server}'. Skipping."
        )
    else:
        logger.info("Configuring Puppet Agent")
        create_puppet_conf(certname, args.server)

    logger.info("Puppet Agent configured successfully")
    return certname


def run_puppet_agent(test_mode=True):
    logger.info("Running Puppet Agent to generate certificate request")

    puppet_bin = "/opt/puppetlabs/bin"
    os.environ["PATH"] = f"{puppet_bin}:{os.environ['PATH']}"

    try:
        cmd = ["puppet", "agent", "--test"]
        if test_mode:
            cmd.append("--noop")

        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        if result.returncode in [0, 1, 2]:
            logger.info("Puppet Agent run completed successfully")
            return True
        else:
            logger.warning("Puppet Agent run completed with errors")
            logger.warning(result.stderr.decode("utf-8"))
            return False
    except Exception as e:
        logger.error(f"Error running Puppet Agent: {e}")
        return False


def is_cert_signed(certname: str) -> bool:
    puppet_bin = "/opt/puppetlabs/bin"
    os.environ["PATH"] = f"{puppet_bin}:{os.environ['PATH']}"

    try:
        result = subprocess.run(
            ["puppet", "ssl", "verify"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False
        )
        return result.returncode == 0
    except Exception as e:
        logger.error(f"Error checking certificate status: {e}")
        return False


def request_certificate_signing(certname: str, server: str) -> bool:
    logger.info(f"Requesting certificate signing for {certname}")

    try:
        puppet_bin = "/opt/puppetlabs/bin"
        os.environ["PATH"] = f"{puppet_bin}:{os.environ['PATH']}"

        logger.info("Waiting for certificate to be signed by server...")
        result = subprocess.run(
            ["puppet", "agent", "--test", "--waitforcert", "0"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

        if is_cert_signed(certname):
            logger.info(f"Certificate for {certname} successfully signed")
            return True
        else:
            logger.info("Certificate signing process did not complete successfully")
            return False

    except Exception as e:
        logger.error(f"Error requesting certificate signing: {e}")
        return False


def check_templates():
    required_templates = ["apt-puppetcore-puppet.conf.j2", "puppet-agent.conf.j2"]

    missing_templates = [template for template in required_templates if not (TEMPLATE_DIR / template).exists()]

    if missing_templates:
        logger.error(f"Missing required template files: {', '.join(missing_templates)}")
        logger.error("Please make sure all template files are in the same directory as this script")
        sys.exit(1)


def main():
    args = parse_arguments()
    logger.info("Starting Puppet Agent installation")

    check_root()
    check_templates()

    try:
        if args.server_ip:
            logger.info(f"Adding hosts entry for {args.server} with IP {args.server_ip}")
            add_hosts_entry(args.server, args.server_ip)

        install_puppet_repo(args.password)
        install_puppet_agent()
        certname = configure_puppet_agent(args)

        run_puppet_agent(test_mode=True)

        if is_cert_signed(certname):
            logger.info(f"Certificate for {certname} is already signed")
            run_puppet_agent(test_mode=False)
        else:
            logger.info("Certificate needs to be signed. Waiting for server to sign it...")
            if request_certificate_signing(certname, args.server):
                logger.info("Certificate signed successfully")
                run_puppet_agent(test_mode=False)
            else:
                logger.warning("Could not complete certificate signing process")
                logger.warning("You may need to manually sign the certificate on the Puppet Server")

        logger.info("Puppet Agent installation completed successfully")
        logger.info(f"Puppet Agent is configured with certificate name: {certname}")
        logger.info(f"Connected to Puppet Server: {args.server}")
        if args.server_ip:
            logger.info(f"Hosts entry added: {args.server_ip} -> {args.server}")

    except subprocess.CalledProcessError as e:
        logger.error(f"Error executing command: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
