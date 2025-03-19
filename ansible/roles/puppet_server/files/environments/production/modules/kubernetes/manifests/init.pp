# @summary Main kubernetes class that manages cluster setup
# @param node_role Type of node (master or worker)
# @param kubernetes_version Kubernetes version to install (semantic version)
# @param crio_version CRI-O version to install (semantic version)
# @param pod_network_cidr CIDR range for pod network
class kubernetes (
  Enum['master', 'worker'] $node_role,
  String $kubernetes_version = 'v1.32',
  String $crio_version       = 'v1.32',
  String $pod_network_cidr   = '10.244.0.0/16',
) {
  class { 'kubernetes::roles::base':
    kubernetes_version => $kubernetes_version,
    crio_version       => $crio_version,
  }

  case $node_role {
    'master': { include kubernetes::roles::master }
    'worker': { include kubernetes::roles::worker }
  }
}
