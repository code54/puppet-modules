class rvm {
  class rvm::dependencies {
    package {
      "build-essential": ensure => installed;
      "curl": ensure => installed;
      "git-core": ensure => installed;
    }
  }
  include rvm::dependencies
  exec { "rvm-install":
    alias   => 'rvm',
    user    => 'root',
    cwd     => "/tmp",
    path    => '/usr/bin:/usr/sbin:/bin',
    unless  => 'which rvm',
    command => "bash -c '/usr/bin/curl -s https://rvm.beginrescueend.com/install/rvm -o rvm-installer ; chmod +x rvm-installer ; rvm_bin_path=/usr/local/rvm/bin rvm_man_path=/usr/local/rvm/man sudo ./rvm-installer'",
    require => Class['rvm::dependencies'], 
  }
  Class["rvm"] -> Package<| provider == rvm |>
}