class kubernetes::master {
  exec { 'kubeadm-init':
    command => 'kubeadm init --v=5 --pod-network-cidr=10.244.0.0/16',
    timeout => 600,
    path    => ['/usr/bin'],
    creates => '/etc/kubernetes/admin.conf',
    require => [
      Service['crio'],
      Exec['swapoff'],
      Exec['load-br_netfilter'],
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
    mode    => '0644',
  }

  file { '/home/vagrant/.kube':
    ensure  => directory,
    source  => '/root/.kube',
    require => File['/root/.kube/config'],
    owner   => 'vagrant',
    recurse => true,
  }

  exec { 'deploy-flannel':
    command => 'kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml',
    path    => ['/usr/bin'],
    require => File['/root/.kube/config'],
    unless  => 'kubectl get daemonset -n kube-flannel | grep flannel',
    logoutput => true,
  }

  file { ['/etc/puppetlabs/facter', '/etc/puppetlabs/facter/facts.d']:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
  }

  exec { 'create_join_command_fact':
    command     => "kubeadm token create --print-join-command > /etc/facter/facts.d/k8s_join_command.txt",
    path        => ['/usr/bin'],
    creates     => '/etc/facter/facts.d/k8s_join_command.txt',
    require     => [File['/etc/puppetlabs/facter/facts.d'], Exec['kubeadm-init']],
  }
}
