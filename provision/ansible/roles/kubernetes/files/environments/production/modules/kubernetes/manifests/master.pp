class kubernetes::master {
  exec { 'kubeadm-init':
    command => 'kubeadm init --v=5 --pod-network-cidr=10.244.0.0/16',
    timeout => 600,
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
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
    mode    => '0600',
  }

  exec { 'setup-kubeconfig-for-user':
    command     => 'mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config',
    path        => ['/usr/bin', '/usr/sbin', '/bin'],
    environment => ['HOME=/home/vagrant'],
    require     => File['/root/.kube/config'],
    creates     => '/home/vagrant/.kube/config',
    logoutput   => true,
  }

  file { '/opt/kubernetes':
    ensure  => directory,
    require => Exec['kubeadm-init'],
  }

  file { '/opt/kubernetes/manifests':
    ensure  => directory,
    require => File['/opt/kubernetes'],
  }

  exec { 'deploy-flannel':
    command => 'kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml',
    path    => ['/usr/bin', '/bin'],
    require => Exec['setup-kubeconfig-for-user'],
    unless  => 'kubectl get daemonset -n kube-flannel | grep -q flannel',
    logoutput => true,
  }
}