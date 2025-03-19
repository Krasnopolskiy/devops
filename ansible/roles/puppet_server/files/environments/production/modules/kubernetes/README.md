# Kubernetes Module

This module installs and configures Kubernetes clusters with CRI-O as the container runtime.

## Description

The Kubernetes module automates the installation and configuration of Kubernetes master and worker nodes. It handles:

- CRI-O installation and configuration
- Kubernetes components (kubelet, kubeadm, kubectl) installation
- Cluster initialization
- CNI networking with Flannel
- Dashboard installation via Helm
- Worker node join automation

## Setup

### What kubernetes affects

* Kernel modules (overlay, br_netfilter)
* Sysctl settings for networking
* Package repositories (Kubernetes and CRI-O)
* Packages (cri-o, kubelet, kubeadm, kubectl)
* Swap configuration (disables swap)
* Kubernetes configuration files
* Helm installation

### Beginning with kubernetes

```puppet
include kubernetes
```

## Usage

### Basic usage

```puppet
class { 'kubernetes':
  node_role => 'master', # or 'worker'
}
```

### Customized installation

```puppet
class { 'kubernetes':
  node_role         => 'master',
  kubernetes_version => 'v1.32',
  crio_version      => 'v1.32',
  pod_network_cidr  => '10.244.0.0/16',
}
```

## Reference

### Classes

#### Public Classes

* `kubernetes`: Main class that installs and configures Kubernetes components.

#### Private Classes

* `kubernetes::roles::base`: Base configuration for all Kubernetes nodes.
* `kubernetes::roles::master`: Configuration specific to master nodes.
* `kubernetes::roles::worker`: Configuration specific to worker nodes.
* `kubernetes::setup::dashboard`: Installs and configures Kubernetes Dashboard.

### Defined Types

* `kubernetes::setup::repository`: Sets up APT repositories.
* `kubernetes::config::kernel_module`: Ensures kernel modules are loaded and configured.
* `kubernetes::config::sysctl`: Configures system control parameters.

### Parameters

#### kubernetes

* `node_role`: Specifies node role ('master' or 'worker'). Default: 'worker'
* `kubernetes_version`: Kubernetes version to install. Default: 'v1.32'
* `crio_version`: CRI-O version to install. Default: 'v1.32'
* `pod_network_cidr`: CIDR range for pod network. Default: '10.244.0.0/16'

## Limitations

This module currently only supports:
* Ubuntu-based systems
* CRI-O as the container runtime
* Flannel as the CNI plugin

## Development

Contributions are welcome via pull requests.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
