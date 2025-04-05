# @summary Installs Helm
# @api private
class kubernetes::setup::helm {
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
}
