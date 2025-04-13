# @summary Installs and configures Kubernetes components
# @param kubernetes_version Version of Kubernetes to install
# @param crio_version Version of CRI-O to install
class kubernetes::roles::base (
  String $kubernetes_version,
  String $crio_version,
) {
  exec { 'swapoff':
    command   => 'swapoff -a',
    path      => ['/sbin', '/usr/sbin', '/usr/bin', '/bin'],
    onlyif    => 'test "$(swapon -s | wc -l)" -gt 1',
    timeout   => 300,
    logoutput => true,
  }

  kubernetes::config::kernel_module { 'overlay':
    kernel_module => 'overlay',
  }

  kubernetes::config::kernel_module { 'load-br-netfilter':
    kernel_module => 'br_netfilter',
  }

  kubernetes::config::sysctl { 'kubernetes-network-settings':
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

  file { '/etc/k8s':
    ensure  => directory,
    recurse => true,
    mode   => '0755',
    source  => 'puppet:///modules/kubernetes/',
  }

  kubernetes::setup::repository { 'kubernetes':
    repo_name => 'kubernetes',
    repo_url  => "https://pkgs.k8s.io/core:/stable:/${kubernetes_version}/deb/",
  }

  kubernetes::setup::repository { 'cri-o':
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
    logoutput   => true,
    timeout     => 600,
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
}
