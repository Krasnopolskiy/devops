# @summary Installs and configures Victoria Metrics
# @api private
class kubernetes::setup::monitoring {
  exec { 'add-victoria-metrics-repo':
    command   => 'helm repo add vm https://victoriametrics.github.io/helm-charts/',
    path      => ['/usr/bin', '/usr/local/bin'],
    unless    => 'helm repo list | grep vm',
    require   => Exec['install-helm'],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'add-grafana-repo':
    command   => 'helm repo add grafana https://grafana.github.io/helm-charts/',
    path      => ['/usr/bin', '/usr/local/bin'],
    unless    => 'helm repo list | grep vm',
    require   => Exec['install-helm'],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'create-monitoring-namespace':
    command     => 'kubectl create namespace monitoring',
    path        => ['/usr/bin', '/bin'],
    unless      => 'kubectl get namespace monitoring',
    logoutput   => true,
  }

  exec { 'create-persistent-volumes':
    command     => "kubectl apply -f /etc/k8s/monitoring/vmcluster/pv.yaml",
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-monitoring-namespace'], File['/etc/k8s']],
    logoutput   => true,
  }

  exec { 'install-vmcluster':
    command     => 'helm upgrade --install -n monitoring vmcluster vm/victoria-metrics-cluster -f /etc/k8s/monitoring/vmcluster/values.yaml',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-monitoring-namespace'], File['/etc/k8s']],
    logoutput   => true,
  }

  exec { 'install-vmagent':
    command     => 'helm upgrade --install -n monitoring vmagent vm/victoria-metrics-agent -f /etc/k8s/monitoring/vmagent/values.yaml',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-monitoring-namespace'], File['/etc/k8s']],
    logoutput   => true,
  }

  exec { 'install-grafana':
    command     => 'helm upgrade --install -n monitoring grafana grafana/grafana -f /etc/k8s/monitoring/grafana/values.yaml',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-monitoring-namespace'], File['/etc/k8s']],
    logoutput   => true,
  }
}
