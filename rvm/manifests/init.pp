class rvm {

  class dependencies {
    package {
      "build-essential": ensure => installed;
      "curl":     ensure => installed;
      "git-core": ensure => installed;
    }
  }

  define user ( $user = 'root' ) {
    exec {'group-assign':
      unless  => "/usr/bin/groups ${user} | grep rvm",
      command => "/usr/sbin/usermod -aG rvm ${user}",
    }
  }

  include dependencies
  user {'rvm::user::root': user => 'root', }

  exec { "rvm-install":
    alias   => 'rvm',
    cwd     => "/tmp",
    path    => '/usr/bin:/usr/sbin:/bin',
    unless  => 'which rvm',
    command => "bash -c '/usr/bin/curl -s https://rvm.beginrescueend.com/install/rvm -o rvm-installer ; chmod +x rvm-installer ; rvm_bin_path=/usr/local/rvm/bin rvm_man_path=/usr/local/rvm/man sudo ./rvm-installer'",
    require => Class['rvm::dependencies'], 
  }

  Class["rvm"] -> Package<| provider == rvm |>

}