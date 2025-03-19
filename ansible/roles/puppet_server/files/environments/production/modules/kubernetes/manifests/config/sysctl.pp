# @summary Configures system control (sysctl) parameters
# @param filename Name of the sysctl configuration file to create
# @param settings Hash of sysctl settings to configure
define kubernetes::config::sysctl(
  String $filename,
  Hash $settings,
) {
  $content = $settings.map |$key, $value| { "${key} = ${value}" }.join("\n")

  file { "/etc/sysctl.d/${filename}":
    ensure  => file,
    mode    => '0644',
    content => "${content}\n",
  }

  exec { "apply-sysctl-${filename}":
    command     => 'sysctl --system',
    path        => ['/sbin', '/usr/sbin'],
    refreshonly => true,
    subscribe   => File["/etc/sysctl.d/${filename}"],
    logoutput   => true,
  }
}
