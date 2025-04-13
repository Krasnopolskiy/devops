# @summary Installs and configures FluentBit
# @api private
class kubernetes::setup::fluentbit {
  exec { 'add-fluentbit-repo':
      command   => 'helm repo add fluent https://fluent.github.io/helm-charts',
    path      => ['/usr/bin', '/usr/local/bin'],
    unless    => 'helm repo list | grep fluent',
    require   => Exec['install-helm'],
    timeout   => 300,
    logoutput => true,
  }

  exec { 'create-fluentbit-namespace':
    command     => 'kubectl create namespace logging',
    path        => ['/usr/bin', '/bin'],
    unless      => 'kubectl get namespace logging',
    logoutput   => true,
  }

  exec { 'install-fluentbit':
    command     => 'helm upgrade --install -n logging fluent-bit fluent/fluent-bit -f /etc/k8s/fluentbit/values.yaml',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-fluentbit-namespace'], File['/etc/k8s']],
    logoutput   => true,
  }
}
