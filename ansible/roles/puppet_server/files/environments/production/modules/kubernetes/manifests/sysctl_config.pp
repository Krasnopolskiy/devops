# @summary Manages sysctl settings in a configuration file
#
# @param filename The name of the sysctl configuration file to create
# @param settings A hash of sysctl settings to apply
define kubernetes::sysctl_config(
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
    command     => '/sbin/sysctl --system',
    refreshonly => true,
    subscribe   => File["/etc/sysctl.d/${filename}"],
  }
} 