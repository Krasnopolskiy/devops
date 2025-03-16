class kubernetes::master {
  exec { 'kubeadm-init':
    command => 'kubeadm init --v=5 --pod-network-cidr=10.244.0.0/16',
    timeout => 600,
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    creates => '/etc/kubernetes/admin.conf',
    require => [
      Service['crio'],
      Exec['swapoff'],
      Exec['load-br-netfilter'],
      Exec['enable-ip-forward'],
    ],
    logoutput => true,
  }

  file { '/root/.kube':
    ensure  => directory,
    require => Exec['kubeadm-init'],
  }

  file { '/root/.kube/config':
    ensure  => file,
    source  => '/etc/kubernetes/admin.conf',
    require => File['/root/.kube'],
    mode    => '0600',
  }

  exec { 'deploy-flannel':
    command => 'kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml',
    path    => ['/usr/bin', '/bin'],
    require => File['/root/.kube/config'],
    unless  => 'kubectl get daemonset -n kube-flannel | grep -q flannel',
    logoutput => true,
  }

  file { '/etc/puppetlabs/facter/facts.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  exec { 'export-join-token':
    command     => 'kubeadm token create --print-join-command > /etc/puppetlabs/facter/facts.d/k8s_join_command.txt',
    path        => ['/usr/bin', '/usr/sbin', '/bin'],
    require     => [File['/etc/puppetlabs/facter/facts.d'], Exec['kubeadm-init']],
    creates     => '/etc/puppetlabs/facter/facts.d/k8s_join_command.txt',
  }
}
