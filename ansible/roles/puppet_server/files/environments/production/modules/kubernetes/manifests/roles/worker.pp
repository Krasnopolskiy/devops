# @summary Configures a Kubernetes worker node
# @api private
class kubernetes::roles::worker {
  $query_result = puppetdb_query("facts { name = 'k8s_join_command' }")

  $join_command = empty($query_result) ? {
    true    => 'echo No join command available yet. Run puppet again later.',
    default => $query_result[0]['value'],
  }

  file { '/tmp/k8s_join_command.sh':
    ensure  => present,
    content => $join_command,
    mode    => '0700',
  }

  exec { 'join-kubernetes-cluster':
    command   => '/bin/bash /tmp/k8s_join_command.sh',
    path      => ['/usr/sbin', '/usr/bin', '/bin'],
    creates   => '/etc/kubernetes/kubelet.conf',
    require   => [
      File['/tmp/k8s_join_command.sh'],
      Service['crio'],
      Exec['swapoff'],
      Kubernetes::Config::Sysctl['kubernetes-network-settings'],
    ],
    tries     => 3,
    try_sleep => 30,
    timeout   => 600,
    logoutput => true,
  }
}
