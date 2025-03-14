# Kubernetes Puppet Module

This Puppet module automates the deployment and configuration of Kubernetes clusters, supporting both master and worker
nodes.

## Overview

This module handles the complete setup of a Kubernetes cluster using kubeadm:

- Repository setup (Kubernetes and CRI-O)
- Package installation
- System configuration for Kubernetes
- Master node initialization
- Worker node joining
- Network plugin deployment (Flannel)

## Features

- Supports both master and worker node roles
- Configurable Kubernetes and CRI-O versions

## Requirements

- Puppet 6.0.0 or higher
- Ubuntu 20.04/22.04 (other distributions may work but are untested)
- Root or sudo access

## Usage

### Master Node

```puppet
class { 'kubernetes':
  node_role          => 'master',
  kubernetes_version => 'v1.32',
  crio_version       => 'v1.32',
}
```

### Worker Node with Auto-Join (requires PuppetDB)

```puppet
class { 'kubernetes':
  node_role          => 'worker',
  kubernetes_version => 'v1.32',
  crio_version       => 'v1.32',
}
```

### Worker Node with Manual Join

```puppet
class { 'kubernetes':
  node_role          => 'worker',
  kubernetes_version => 'v1.32',
  crio_version       => 'v1.32',
}
```

## Parameters

| Parameter          | Type                     | Description                          | Default  |
|--------------------|--------------------------|--------------------------------------|----------|
| node_role          | Enum['master', 'worker'] | The role of this node in the cluster | 'worker' |
| kubernetes_version | String                   | Kubernetes version to install        | 'v1.32'  |
| crio_version       | String                   | CRI-O version to install             | 'v1.32'  |

## How it Works

### Master Node

1. Installs necessary packages
2. Initializes the Kubernetes control plane
3. Sets up kubectl configuration
4. Deploys Flannel for pod networking

### Worker Node

1. Installs necessary packages
2. Creates a placeholder script for joining
3. Notifies the administrator to run the join command manually

## License

Apache License 2.0