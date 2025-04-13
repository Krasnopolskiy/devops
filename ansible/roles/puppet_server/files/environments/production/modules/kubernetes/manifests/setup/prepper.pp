# @summary Installs and configures Prepper
# @api private
class kubernetes::setup::prepper {
  exec { 'create-prepper-namespace':
    command     => 'kubectl create namespace logging',
    path        => ['/usr/bin', '/bin'],
    unless      => 'kubectl get namespace logging',
    logoutput   => true,
  }

  exec { 'install-prepper':
    command     => 'helm upgrade --install -n logging prepper /etc/k8s/prepper',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create-join-command-fact'], File['/etc/k8s']],
    logoutput   => true,
  }
}
