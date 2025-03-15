node /^k8s-master/ {
  class { 'kubernetes': node_role => 'master' }
}

node /^k8s-worker/ {
  class { 'kubernetes': node_role => 'worker' }
}

node default { }