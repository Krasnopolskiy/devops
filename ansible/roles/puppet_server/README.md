# Puppet Server Role

Ansible role to install and configure Puppet Server with PuppetDB on Ubuntu.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9 or higher

## Dependencies

- puppet_common role

## Role Variables

| Variable                            | Default Value          | Description                            |
|-------------------------------------|------------------------|----------------------------------------|
| puppet_server_java_heap_size        | "1g"                   | Java heap size for Puppet Server       |
| puppet_server_environment_dir       | /etc/puppetlabs/code   | Puppet code environment directory      |
| puppet_server_conf_dir              | /etc/puppetlabs/puppet | Puppet configuration directory         |
| puppet_server_db.user               | puppetdb               | PuppetDB database user                 |
| puppet_server_db.password           | puppetdb               | PuppetDB database password             |
| puppet_server_db.name               | puppetdb               | PuppetDB database name                 |
| puppet_server_db.max_connections    | 60                     | Maximum database connections           |
| puppet_server_db.connection_timeout | 3600                   | Database connection timeout            |
| puppet_server_db.listen.address     | "0.0.0.0"              | Network address for PuppetDB to listen |
| puppet_server_db.listen.port        | 8081                   | Port for PuppetDB to listen on         |
| server_ip                           | (required)             | IP address of the Puppet Server        |
| certname                            | (required)             | Certificate name for the Puppet Server |

## Example Playbook

```yaml
- hosts: puppet_servers
  roles:
    - role: puppet_server
      vars:
        server_ip: "192.168.1.10"
        certname: "puppet.example.com"
        puppet_server_java_heap_size: "2g"
```

## Tasks Structure

The role is organized into the following task files:

- `setup.yml`: Installation of Puppet Server and initial setup
- `config.yml`: Configuration of Puppet Server including Java heap size
- `service.yml`: Service management tasks (enabling, starting)
- `puppetdb.yml`: Installation and configuration of PuppetDB
- `environments.yml`: Puppet environment deployment tasks

## Tags

- setup: Installation tasks
- config: Configuration tasks
- service: Service management tasks
- puppetdb: PuppetDB installation and configuration tasks
- environments: Puppet environment deployment tasks
- puppet_server: All tasks related to this role

## License

MIT