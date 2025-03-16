class kubernetes::common (
  String $kubernetes_version,
  String $crio_version,
) {
  exec { 'swapoff':
    command => '/sbin/swapoff -a',
    onlyif  => '/usr/bin/test "$(swapon -s | wc -l)" -gt 1',
  }

  kubernetes::load_kernel_module { 'load-overlay':
    kernel_module => 'overlay',
  }

  kubernetes::load_kernel_module { 'load-br-netfilter':
    kernel_module => 'br_netfilter',
  }

  kubernetes::sysctl_config { 'kubernetes-network-settings':
    filename => 'k8s.conf',
    settings => {
      'net.bridge.bridge-nf-call-ip6tables' => 1,
      'net.bridge.bridge-nf-call-iptables'  => 1,
      'net.ipv4.ip_forward'                 => 1,
    },
  }

  package { ['software-properties-common', 'curl', 'iptables']:
    ensure => installed,
  }

  file { '/etc/apt/keyrings':
    ensure => directory,
    mode   => '0755',
  }

  kubernetes::add_repository { 'add-kubernetes-package':
    repo_name => 'kubernetes',
    repo_url  => "https://pkgs.k8s.io/core:/stable:/${kubernetes_version}/deb/",
  }

  kubernetes::add_repository { 'add-cri-o-package':
    repo_name => 'cri-o',
    repo_url  => "https://download.opensuse.org/repositories/isv:/cri-o:/stable:/${crio_version}/deb/",
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
