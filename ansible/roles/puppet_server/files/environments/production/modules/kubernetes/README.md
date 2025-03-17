# Kubernetes Module

This module manages Kubernetes master and worker nodes.

## Usage

```puppet
class { 'kubernetes':
  node_role => 'master', # or 'worker'
}
```