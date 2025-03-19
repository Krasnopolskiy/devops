# Ansible Playbooks

This directory contains Ansible playbooks for deploying and configuring Puppet infrastructure.

## Available Playbooks

| Playbook                                 | Description                                           |
|------------------------------------------|-------------------------------------------------------|
| [puppet_server.yml](./puppet_server.yml) | Installs and configures Puppet Server on target hosts |
| [puppet_agent.yml](./puppet_agent.yml)   | Configures Puppet Agent on target hosts               |

## puppet_server.yml

Deploys and configures a Puppet Server node.

### Host Groups:

- `puppet_server`

### Required Variables:

- `puppet_password`: API key for Puppet (must be set as environment variable `PUPPET_API_KEY`)

### Roles Applied:

- `puppet_common`: Common Puppet configurations
- `puppet_server`: Puppet Server specific configurations

### Example Usage:

```bash
PUPPET_API_KEY=yourpassword ansible-playbook puppet_server.yml
```

## puppet_agent.yml

Configures Puppet Agent nodes to connect to a Puppet Server.

### Host Groups:

- `puppet_agent`

### Required Variables:

- `puppet_password`: API key for Puppet (must be set as environment variable `PUPPET_API_KEY`)
- `server_ip`: The IP address of the Puppet Server (derived from inventory when available)

### Roles Applied:

- `puppet_common`: Common Puppet configurations
- `puppet_agent`: Puppet Agent specific configurations

### Example Usage:

```bash
PUPPET_API_KEY=yourpassword ansible-playbook puppet_agent.yml
``` 