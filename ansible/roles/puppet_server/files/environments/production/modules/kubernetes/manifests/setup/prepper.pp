# @summary Installs and configures Prepper
# @api private
class kubernetes::setup::prepper {
  exec { 'create-prepper-namespace':
    command     => 'kubectl create namespace logging',
    path        => ['/usr/bin', '/bin'],
    unless      => 'kubectl get namespace logging',
    logoutput   => true,
  }

  file { '/etc/k8s/prepper':
    ensure  => directory,
    source  => 'puppet:///modules/kubernetes/logging/prepper',
    require => File['/etc/k8s'],
    recurse => true,
    replace => true,
  }

  exec { 'install-prepper':
    command     => 'helm upgrade --install -n logging prepper /etc/k8s/prepper',
    path        => ['/usr/bin', '/usr/local/bin'],
    require     => [Exec['create_join_command_fact'], File['/etc/k8s/prepper']],
    logoutput   => true,
  }
}
