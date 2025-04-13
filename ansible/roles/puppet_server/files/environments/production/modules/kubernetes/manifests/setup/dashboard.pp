# @summary Installs and configures Kubernetes Dashboard
# @api private
class kubernetes::setup::dashboard {
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
      'helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard',
    path      => ['/usr/local/bin', '/usr/bin'],
    unless    => 'helm list -n kubernetes-dashboard | grep kubernetes-dashboard',
    require   => [Exec['create-join-command-fact'], Exec['add-dashboard-repo']],
    timeout   => 600,
    tries     => 3,
    try_sleep => 30,
    logoutput => true,
  }

  exec { 'apply-service-account':
    command   => 'kubectl apply -f /etc/k8s/dashboard/kubernetes-dashboard.yaml',
    path      => ['/usr/bin', '/bin'],
    unless    => 'kubectl get serviceaccount -n kubernetes-dashboard admin-user',
    require   => [Exec['install-dashboard'], File['/etc/k8s']],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'apply-cluster-role-binding':
    command   => 'kubectl apply -f /etc/k8s/dashboard/roles.yaml',
    path      => ['/usr/bin', '/bin'],
    unless    => 'kubectl get clusterrolebinding admin-user',
    require   => [Exec['apply-service-account'], File['/etc/k8s']],
    timeout   => 300,
    logoutput => true,
  }
}
