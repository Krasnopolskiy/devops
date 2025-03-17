class kubernetes::worker {
  $query_result = puppetdb_query("facts { name = 'k8s_join_command' and certname = 'k8s-master.redfield.tech' }")

  $join_command = empty($query_result) ? {
    true    => 'No join command available yet. Run puppet again later.',
    default => $query_result[0]['value'],
  }

  file { '/tmp/k8s_join_command.sh':
    ensure  => present,
    content => $join_command,
    mode    => '0700',
  }

  exec { 'join-kubernetes-cluster':
    command   => '/bin/bash /tmp/k8s_join_command.sh',
    path      => ['/usr/sbin', '/usr/bin'],
    creates   => '/etc/kubernetes/kubelet.conf',
    require   => File['/tmp/k8s_join_command.sh'],
    logoutput => true,
  }
}
