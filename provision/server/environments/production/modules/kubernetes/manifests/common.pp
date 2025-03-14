class kubernetes::common (
  String $kubernetes_version,
  String $crio_version,
) {
  exec { 'swapoff':
    command => '/sbin/swapoff -a',
    onlyif  => '/usr/bin/test "$(swapon -s | wc -l)" -gt 1',
  }

  ['overlay', 'br_netfilter'].each |String $module| {
    exec { "load-${module}":
      command => "/sbin/modprobe ${module}",
      unless  => "/bin/lsmod | /bin/grep -q ${module}",
    }

    file { "/etc/modules-load.d/${module}.conf":
      ensure  => file,
      content => "${module}\n",
      mode    => '0644',
    }
  }

  file { '/etc/sysctl.d/k8s.conf':
    ensure  => file,
    mode    => '0644',
    content => "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
",
  }

  exec { 'apply-sysctl-settings':
    command     => '/sbin/sysctl --system',
    refreshonly => true,
    subscribe   => File['/etc/sysctl.d/k8s.conf'],
  }

  package { ['software-properties-common', 'curl', 'iptables']:
    ensure => installed,
  }

  file { '/etc/apt/keyrings':
    ensure => directory,
    mode   => '0755',
  }

  exec { 'download-kubernetes-key':
    command => "curl -fsSL https://pkgs.k8s.io/core:/stable:/${kubernetes_version}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
    path    => ['/usr/bin', '/bin'],
    creates => '/etc/apt/keyrings/kubernetes-apt-keyring.gpg',
    require => File['/etc/apt/keyrings'],
  }

  file { '/etc/apt/sources.list.d/kubernetes.list':
    ensure  => file,
    content => "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${kubernetes_version}/deb/ /",
    require => Exec['download-kubernetes-key'],
  }

  exec { 'download-crio-key':
    command => "curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/${crio_version}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg",
    path    => ['/usr/bin', '/bin'],
    creates => '/etc/apt/keyrings/cri-o-apt-keyring.gpg',
    require => File['/etc/apt/keyrings'],
  }

  file { '/etc/apt/sources.list.d/cri-o.list':
    ensure  => file,
    content => "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/${crio_version}/deb/ /",
    require => Exec['download-crio-key'],
  }

  exec { 'apt-update':
    command     => 'apt-get update',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    subscribe   => [
      File['/etc/apt/sources.list.d/kubernetes.list'],
      File['/etc/apt/sources.list.d/cri-o.list'],
    ],
  }

  package { ['cri-o', 'kubelet', 'kubeadm', 'kubectl']:
    ensure  => installed,
    require => Exec['apt-update'],
  }

  service { 'crio':
    ensure  => running,
    enable  => true,
    require => Package['cri-o'],
  }

  exec { 'enable-ip-forward':
    command => 'sysctl -w net.ipv4.ip_forward=1',
    path    => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
    unless  => 'sysctl net.ipv4.ip_forward | grep -q "net.ipv4.ip_forward = 1"',
  }
}