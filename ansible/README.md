# Ansible Configuration

This directory contains Ansible configuration for deploying and configuring Puppet infrastructure.

## Directory Structure

```
ansible/
├── .ansible/           # Ansible runtime files
├── ansible.cfg         # Ansible configuration
├── inventory.yml       # Inventory of hosts
├── playbooks/          # Playbook definitions
│   ├── puppet_agent.yml    # Configures Puppet agents
│   └── puppet_server.yml   # Installs and configures Puppet server
└── roles/              # Role definitions
    ├── puppet_agent/       # Role for Puppet agent nodes
    ├── puppet_common/      # Common configuration for all Puppet nodes
    └── puppet_server/      # Role for Puppet server
```

## Inventory

The `inventory.yml` file defines the following host groups:

- `puppet_server`: Hosts running Puppet Server
- `puppet_agent`: Hosts running Puppet Agent
- `k8s_workers`: Kubernetes worker nodes

## Playbooks

- **puppet_server.yml**: Installs and configures a Puppet Server
- **puppet_agent.yml**: Configures Puppet Agent on nodes

## Roles

- **puppet_common**: Common configuration shared between Puppet server and agents
- **puppet_server**: Specific configuration for Puppet server
- **puppet_agent**: Specific configuration for Puppet agents

## Configuration

The `ansible.cfg` file contains important settings:

- Uses `inventory.yml` as the inventory source
- Disables host key checking for easier automation
- Sets role path to `./roles`
- Configures SSH pipelining for better performance
- Sets Python interpreter to auto-silent mode

## Usage

To run a playbook:

```bash
ansible-playbook playbooks/puppet_server.yml
```

To run with specific variables:

```bash
PUPPET_API_KEY=yourpassword ansible-playbook playbooks/puppet_server.yml
```

## Requirements

- Ansible 2.9+
- SSH access to target hosts
- Proper environment variables set (e.g., PUPPET_API_KEY) 