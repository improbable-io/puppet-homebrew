class homebrew::install {

  # if $homebrew::multiuser == true {
  #   file { '/usr/local/Homebrew':
  #     ensure => directory,
  #     owner  => $homebrew::user,
  #     group  => $homebrew::group,
  #   }
  #   exec { 'chmod-brew':
  #     command => '/bin/chmod -R 775 /usr/local',
  #     unless  => '/usr/bin/stat -f "%OLp" /usr/local | /usr/bin/grep -w "775"',
  #   }
  #   exec { 'chown-brew':
  #     command => "/usr/sbin/chown -R :${homebrew::group} /usr/local",
  #     unless  => "/usr/bin/stat -f '%Su' /usr/local | /usr/bin/grep -w '${homebrew::group}'",
  #   }
  #   exec { 'set-brew-directory-inherit':
  #     command => "/bin/chmod -R +a 'group:${homebrew::group} allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit' /usr/local",
  #     unless  => '/usr/bin/stat -f "%OLp" /usr/local | /usr/bin/grep -w "775"',
  #   }
  # }
  
  file { 'brew-usr-local-bin':
    ensure => directory,
    path   => '/usr/local/bin',
  }
  exec { 'set-usr-local-bin-directory-inherit':
    command     => "/bin/chmod -R +a 'group:staff allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit' /usr/local/bin",
    refreshonly => true,
  }

  $brew_folders = [
    '/usr/local/Homebrew',
    '/usr/local/Caskroom',
    '/usr/local/Cellar',
  ]
  file { $brew_folders:
    ensure => directory,
    owner  => $homebrew::user,
    group  => $homebrew::group,
  }

  if $homebrew::multiuser == true {
    $brew_folders.each | String $brew_folder | {
      exec { "chmod-${brew_folder}":
        command => "/bin/chmod -R 775 ${brew_folder}",
        unless  => "/usr/bin/stat -f '%OLp' ${brew_folder} | /usr/bin/grep -w '775'",
      }
      exec { "chown-${brew_folder}":
        command => "/usr/sbin/chown -R :${homebrew::group} ${brew_folder}",
        unless  => "/usr/bin/stat -f '%Su' ${brew_folder} | /usr/bin/grep -w '${homebrew::group}'",
      }
      exec { "set-${brew_folder}-directory-inherit":
        command     => "/bin/chmod -R +a 'group:${homebrew::group} allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit' ${brew_folder}",
        refreshonly => true,
      }
    }
  }

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

}
