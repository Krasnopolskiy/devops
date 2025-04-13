# @summary Installs Helm
# @api private
class kubernetes::setup::helm {
  exec { 'install-helm':
    command   => '/bin/bash /etc/k8s/get-helm-3.sh',
    path      => ['/usr/bin', '/usr/local/bin', '/bin'],
    creates   => '/usr/local/bin/helm',
    require   => [Exec['deploy-flannel'], File['/etc/k8s']],
    timeout   => 600,
    logoutput => true,
  }
}
