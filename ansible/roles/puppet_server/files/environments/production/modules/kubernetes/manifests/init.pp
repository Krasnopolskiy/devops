class kubernetes (
  Enum['master', 'worker'] $node_role = 'worker',
  String $kubernetes_version = 'v1.32',
  String $crio_version = 'v1.32',
) {
  class { 'kubernetes::common':
    kubernetes_version => $kubernetes_version,
    crio_version       => $crio_version,
  }

  case $node_role {
    'master': { include kubernetes::master }
    'worker': { include kubernetes::worker }
  }
}
