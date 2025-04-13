# @summary Installs and configures Opensearch
# @api private
class kubernetes::setup::opensearch {
  exec { 'add-opensearch-repo':
      command   => 'helm repo add opensearch https://opensearch-project.github.io/helm-charts/',
    path      => ['/usr/bin', '/usr/local/bin'],
    unless    => 'helm repo list | grep opensearch',
    require   => Exec['install-helm'],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'create-opensearch-namespace':
    command     => 'kubectl create namespace logging',
    path        => ['/usr/bin', '/bin'],
    unless      => 'kubectl get namespace logging',
    logoutput   => true,
  }

  exec { 'create-persistent-volumes':
    command     => "kubectl apply -f /etc/k8s/opensearch/pv.yaml",
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-opensearch-namespace'], File['/etc/k8s']],
    logoutput   => true,
  }

  exec { 'install-opensearch':
    command     => 'helm upgrade --install -n logging opensearch opensearch/opensearch -f /etc/k8s/opensearch/values.yaml',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-fluentbit-namespace'], File['/etc/k8s']],
    logoutput   => true,
  }

  exec { 'install-opensearch-dashboards':
    command     => 'helm upgrade --install -n logging opensearch-dashboards opensearch/opensearch-dashboards -f /etc/k8s/opensearch/values.yaml',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['install-opensearch']],
    logoutput   => true,
  }
}
