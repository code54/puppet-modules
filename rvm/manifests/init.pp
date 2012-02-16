class rvm {

  class dependencies {
    package {
      "build-essential": ensure => installed;
      "curl":     ensure => installed;
      "git-core": ensure => installed;
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
