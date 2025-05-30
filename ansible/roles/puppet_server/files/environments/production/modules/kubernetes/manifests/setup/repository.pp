# @summary Sets up an APT repository for Kubernetes components
# @param repo_name Name of the repository
# @param repo_url URL of the repository
define kubernetes::setup::repository (
  String $repo_name,
  String $repo_url,
) {
  $key_url = "${repo_url}Release.key"

  exec { "download-${repo_name}-key":
    command   => "curl -fsSL ${key_url} | gpg --dearmor -o /etc/apt/keyrings/${repo_name}-apt-keyring.gpg",
    path      => ['/usr/bin', '/bin'],
    creates   => "/etc/apt/keyrings/${repo_name}-apt-keyring.gpg",
    require   => File['/etc/apt/keyrings'],
    tries     => 3,
    try_sleep => 10,
    timeout   => 300,
    logoutput => true,
  }

  file { "/etc/apt/sources.list.d/${repo_name}.list":
    ensure  => file,
    content => "deb [signed-by=/etc/apt/keyrings/${repo_name}-apt-keyring.gpg] ${repo_url} /",
    require => Exec["download-${repo_name}-key"],
  }
}
