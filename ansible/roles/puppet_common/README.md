# Puppet Common Role

Ansible role containing common tasks for Puppet installation on Ubuntu.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9 or higher

## Role Variables

| Variable                     | Default Value                      | Description                                   |
|------------------------------|------------------------------------|-----------------------------------------------|
| puppet_common_version        | 8                                  | Puppet version to install                     |
| puppet_common_ubuntu_release | {{ ansible_distribution_release }} | Ubuntu release codename                       |
| puppet_password              | (required)                         | Password for Puppet repository authentication |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: puppet_common
      vars:
        puppet_version: 7
        ubuntu_release: "{{ ansible_distribution_release }}"
        puppet_password: "mypassword"
```

## Tags

- repository: Repository setup tasks
- install: Common installation tasks
- puppet_common: All tasks in this role

## License

MIT