# @summary Configures a Kubernetes master node
# @api private
class kubernetes::roles::master (
  String $pod_network_cidr = $kubernetes::pod_network_cidr,
) {
  include kubernetes::setup::dashboard
  
  exec { 'kubeadm-init':
    command   => "kubeadm init --v=5 --pod-network-cidr=${pod_network_cidr}",
    timeout   => 1200,
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    creates   => '/etc/kubernetes/admin.conf',
    tries     => 3,
    try_sleep => 60,
    require   => [
      Service['crio'],
      Exec['swapoff'],
      Kubernetes::Config::Sysctl['kubernetes-network-settings'],
      Kubernetes::Config::Kernel_module['load-br-netfilter'],
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

  file { '/tmp/kube-flannel.yml':
    ensure => file,
    source => 'puppet:///modules/kubernetes/kube-flannel.yml',
    before => Exec['deploy-flannel'],
  }

  exec { 'deploy-flannel':
    command   => 'kubectl apply -f /tmp/kube-flannel.yml',
    path      => ['/usr/bin', '/bin'],
    require   => File['/root/.kube/config'],
    unless    => 'kubectl get daemonset -n kube-flannel | grep flannel',
    tries     => 3,
    try_sleep => 30,
    timeout   => 300,
    logoutput => true,
  }

  file { ['/etc/facter', '/etc/facter/facts.d']:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
  }

  exec { 'create_join_command_fact':
    command     => "kubeadm token create --print-join-command > /etc/facter/facts.d/k8s_join_command_output.txt && echo k8s_join_command=$(cat /etc/facter/facts.d/k8s_join_command_output.txt) > /etc/facter/facts.d/k8s_join_command.txt && rm /etc/facter/facts.d/k8s_join_command_output.txt",
    path        => ['/usr/bin', '/bin'],
    creates     => '/etc/facter/facts.d/k8s_join_command.txt',
    require     => [File['/etc/facter/facts.d'], Exec['kubeadm-init']],
    logoutput   => true,
  }
}
