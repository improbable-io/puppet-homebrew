class homebrew::install {

  file { '/usr/local/Homebrew':
    ensure => directory,
    owner  => $homebrew::user,
    group  => $homebrew::group,
  } ->
  exec { 'install-homebrew':
    cwd       => '/usr/local/Homebrew',
    command   => "/usr/bin/su ${homebrew::user} -c '/bin/bash -o pipefail -c \"/usr/bin/curl -skSfL https://github.com/homebrew/brew/tarball/master | /usr/bin/tar xz -m --strip 1\"'",
    creates   => '/usr/local/Homebrew/bin/brew',
    logoutput => on_failure,
    timeout   => 0,
  } ~>
  file { '/usr/local/bin/brew':
    ensure => 'link',
    target => '/usr/local/Homebrew/bin/brew',
    owner  => $homebrew::user,
    group  => $homebrew::group,
  }

  if $homebrew::multiuser == true {
    exec { 'chmod-brew':
      command => '/bin/chmod -R 775 /usr/local',
      unless  => '/usr/bin/stat -f "%OLp" /usr/local | grep -w "775"',
    }
    exec { 'chown-brew':
      command => "/usr/sbin/chown -R ${homebrew::user}:${homebrew::group} /usr/local",
      unless  => "/usr/bin/stat -f '%Su' /usr/local | grep -w '${homebrew::user}' && stat -f '%Su' /usr/local | grep -w '${homebrew::group}'",
    }
  }

}
