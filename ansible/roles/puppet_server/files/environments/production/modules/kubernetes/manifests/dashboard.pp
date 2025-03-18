class kubernetes::dashboard {
  exec { 'install-helm':
    command => 'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash',
    path    => ['/usr/bin', '/usr/local/bin'],
    creates => '/usr/local/bin/helm',
    require => Package['curl'],
  }

  exec { 'add-dashboard-repo':
    command => 'helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/',
    path    => ['/usr/bin', '/usr/local/bin'],
    unless  => 'helm repo list | grep kubernetes-dashboard',
    require => Exec['install-helm'],
  }

  exec { 'install-dashboard':
    command => 'helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard',
    path    => ['/usr/local/bin', '/usr/bin'],
    unless  => 'helm list -n kubernetes-dashboard | grep kubernetes-dashboard',
    require => Exec['add-dashboard-repo'],
  }

  file { '/tmp/kubernetes-dashboard.yaml':
    ensure  => file,
    content => @(EOT)
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOT
    ,
  }

  file { '/tmp/roles.yaml':
    ensure  => file,
    content => @(EOT)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOT
    ,
  }

  exec { 'apply-serviceaccount':
    command => 'kubectl apply -f /tmp/kubernetes-dashboard.yaml',
    path    => ['/usr/bin'],
    require => [File['/tmp/kubernetes-dashboard.yaml']],
  }

  exec { 'apply-cluster-role-binding':
    command => 'kubectl apply -f /tmp/roles.yaml',
    path    => ['/usr/bin'],
    require => File['/tmp/roles.yaml'],
  }

  exec { 'create-admin-token':
    command => 'kubectl -n kubernetes-dashboard create token admin-user',
    path    => ['/usr/bin'],
    require => Exec['apply-cluster-role-binding'],
    logoutput => true,
  }
}
