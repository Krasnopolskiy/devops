define kubernetes::load_kernel_module(
  String $kernel_module,
) {
  exec { "load-${kernel_module}":
    command => "/sbin/modprobe ${kernel_module}",
    unless  => "/bin/lsmod | /bin/grep -q ${kernel_module}",
  }

  file { "/etc/modules-load.d/${kernel_module}.conf":
    ensure  => file,
    content => "${kernel_module}\n",
    mode    => '0644',
  }
}
