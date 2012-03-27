class rvm {

  class dependencies {
    case $::operatingsystem {
      'centos', 'redhat', 'fedora': {
        $dependencies_names = ['gcc-c++', 'patch', 'readline', 'readline-devel', 'zlib', 'zlib-devel', 'libyaml-devel',
        'libffi-devel', 'openssl-devel', 'make', 'bzip2', 'autoconf', 'automake', 'libtool', 'bison', 'file']
      }
      'ubuntu', 'debian': {
        $dependencies_names = ["build-essential", "curl", "git-core"]
      }
      default: {
        fail "Unknwonw RVM dependencies for ${::operatingsystem}"
      }
    }

    package {"rvm_dependencies":
      name => $dependencies_names,
      ensure => installed;
    }
  }

  define user ( $user = 'root' ) {
    exec {"group-assign-${user}":
      unless  => "/usr/bin/groups ${user} | grep rvm",
      command => "/usr/sbin/usermod -aG rvm ${user}",
      require => Exec['rvm-install']
    }
  }

  include dependencies
  ::rvm::user {'rvm::user::root': user => 'root', }

  exec { "rvm-install":
    alias   => 'rvm',
    cwd     => "/tmp",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/rvm/bin',
    user    => 'root',
    unless  => 'which rvm',
    command => "curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable",
    require => Class['rvm::dependencies'],
  }

  Class["rvm"] -> Package<| provider == rvm |>

  define gemset($ruby, $gemset) {
    exec {"create ${ruby}@${gemset}":
      command => "bash -lc 'rvm use ${ruby}@${gemset} --create'",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/rvm/bin',
      require => Package[$ruby],
      creates => "/usr/local/rvm/gems/${ruby}@${gemset}",
    }
  }
}
