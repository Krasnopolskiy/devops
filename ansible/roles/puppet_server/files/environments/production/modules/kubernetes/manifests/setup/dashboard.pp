# @summary Installs and configures Kubernetes Dashboard
# @api private
class kubernetes::setup::dashboard {
  file { '/tmp/get-helm-3.sh':
    ensure => file,
    source => 'puppet:///modules/kubernetes/get-helm-3.sh',
    mode   => '0755',
    before => Exec['install-helm'],
  }

  exec { 'install-helm':
    command   => '/bin/bash /tmp/get-helm-3.sh',
    path      => ['/usr/bin', '/usr/local/bin', '/bin'],
    creates   => '/usr/local/bin/helm',
    require   => [
      Exec['deploy-flannel'],
      File['/tmp/get-helm-3.sh'],
    ],
    timeout   => 600,
    logoutput => true,
  }

  exec { 'add-dashboard-repo':
    command   => 'helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ && helm repo update',
    path      => ['/usr/bin', '/usr/local/bin'],
    unless    => 'helm repo list | grep kubernetes-dashboard',
    require   => Exec['install-helm'],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'install-dashboard':
    command   =>
      'helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard'
    ,
    path      => ['/usr/local/bin', '/usr/bin'],
    unless    => 'helm list -n kubernetes-dashboard | grep kubernetes-dashboard',
    require   => Exec['add-dashboard-repo'],
    timeout   => 600,
    tries     => 3,
    try_sleep => 30,
    logoutput => true,
  }

  file { '/tmp/kubernetes-dashboard.yaml':
    ensure => file,
    source => 'puppet:///modules/kubernetes/kubernetes-dashboard.yaml',
  }

  file { '/tmp/roles.yaml':
    ensure => file,
    source => 'puppet:///modules/kubernetes/roles.yaml',
  }

  exec { 'apply-service-account':
    command   => 'kubectl apply -f /tmp/kubernetes-dashboard.yaml',
    path      => ['/usr/bin', '/bin'],
    unless    => 'kubectl get serviceaccount -n kubernetes-dashboard admin-user',
    require   => [Exec['install-dashboard'], File['/tmp/kubernetes-dashboard.yaml']],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'apply-cluster-role-binding':
    command   => 'kubectl apply -f /tmp/roles.yaml',
    path      => ['/usr/bin', '/bin'],
    unless    => 'kubectl get clusterrolebinding admin-user',
    require   => [Exec['apply-service-account'], File['/tmp/roles.yaml']],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'create-admin-token':
    command   => 'kubectl -n kubernetes-dashboard create token admin-user > /root/kubernetes-dashboard-token.txt',
    path      => ['/usr/bin', '/bin'],
    creates   => '/root/kubernetes-dashboard-token.txt',
    require   => Exec['apply-cluster-role-binding'],
    logoutput => true,
  }

  file { '/root/kubernetes-dashboard-token.txt':
    ensure  => file,
    mode    => '0600',
    require => Exec['create-admin-token'],
  }
}
