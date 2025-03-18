class kubernetes::master {
  exec { 'kubeadm-init':
    command => 'kubeadm init --v=5 --pod-network-cidr=10.244.0.0/16',
    timeout => 600,
    path    => ['/usr/bin', '/usr/sbin'],
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

  file { ['/etc/facter', '/etc/facter/facts.d']:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
  }

  exec { 'create_join_command_fact':
    command     => "echo k8s_join_command=$(kubeadm token create --print-join-command) > /etc/facter/facts.d/k8s_join_command.txt",
    path        => ['/usr/bin'],
    creates     => '/etc/facter/facts.d/k8s_join_command.txt',
    require     => [File['/etc/facter/facts.d'], Exec['kubeadm-init']],
  }

  exec { 'install-helm':
    command => 'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash',
    path    => ['/usr/bin', '/usr/local/bin'],
    creates => '/usr/local/bin/helm',
    require => Exec['deploy-flannel'],
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

  exec { 'apply-service-account':
    command => 'kubectl apply -f /tmp/kubernetes-dashboard.yaml',
    path    => ['/usr/bin'],
    require => [Exec['add-dashboard-repo'], File['/tmp/kubernetes-dashboard.yaml']],
  }

  exec { 'apply-cluster-role-binding':
    command => 'kubectl apply -f /tmp/roles.yaml',
    path    => ['/usr/bin'],
    require => [Exec['add-dashboard-repo'], File['/tmp/roles.yaml']],
  }

  exec { 'create-admin-token':
    command => 'kubectl -n kubernetes-dashboard create token admin-user',
    path    => ['/usr/bin'],
    require => Exec['apply-cluster-role-binding'],
    logoutput => true,
  }
}
