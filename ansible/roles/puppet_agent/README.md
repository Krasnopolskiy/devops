# Puppet Agent Role

Ansible role to install and configure Puppet Agent on Ubuntu.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9 or higher

## Dependencies

- puppet_common role

## Role Variables

| Variable                   | Default Value          | Description                                     |
|----------------------------|------------------------|-------------------------------------------------|
| puppet_agent_conf_dir      | /etc/puppetlabs/puppet | Puppet configuration directory                  |
| puppet_agent_wait_for_cert | 60                     | Time in seconds to wait for certificate signing |
| puppet_agent_run_interval  | 30                     | Run interval for Puppet agent in minutes        |
| puppet_agent_environment   | production             | Environment to use                              |
| server_ip                  | (required)             | IP address of the Puppet Server                 |
| server_certname            | (required)             | Certificate name of the Puppet Server           |
| certname                   | (required)             | Certificate name for the Puppet Agent           |

## Example Playbook

```yaml
- hosts: puppet_agents
  roles:
    - role: puppet_agent
      vars:
        server_ip: "192.168.1.10"
        server_certname: "puppet.example.com"
        certname: "{{ inventory_hostname }}"
        puppet_agent_wait_for_cert: 120
```

## Tasks Structure

The role is organized into the following task files:

- `verify.yml`: Validation and hosts file configuration
- `install.yml`: Puppet Agent installation
- `config.yml`: Configuration and certificate management
- `service.yml`: Service management and status reporting

## Tags

- verify: Verification tasks
- install: Installation tasks
- config: Configuration tasks
- service: Service management tasks
- cert: Certificate-related tasks
- puppet_agent: All tasks related to this role

## License

MIT