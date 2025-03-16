class kubernetes::worker {
  file { '/tmp/k8s_join_command.txt.sh':
    ensure  => present,
    content => $facts['k8s_join_command'],
    mode    => '0700',
  }

  exec { 'join-kubernetes-cluster':
    command   => '/bin/bash /tmp/k8s_join_command.txt.sh',
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    creates   => '/etc/kubernetes/kubelet.conf',
    require   => File['/tmp/k8s_join_command.txt.sh'],
    logoutput => true,
  }
}
