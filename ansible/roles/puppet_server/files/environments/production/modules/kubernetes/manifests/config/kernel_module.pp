# @summary Ensures kernel modules are loaded and configured to load on boot
# @param kernel_module Name of the kernel module to load
define kubernetes::config::kernel_module(
  String $kernel_module,
) {
  exec { "load-${kernel_module}":
    command   => "modprobe ${kernel_module}",
    path      => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
    unless    => "lsmod | grep -q ${kernel_module}",
    logoutput => true,
  }

  file { "/etc/modules-load.d/${kernel_module}.conf":
    ensure  => file,
    content => "${kernel_module}\n",
    mode    => '0644',
  }
}
