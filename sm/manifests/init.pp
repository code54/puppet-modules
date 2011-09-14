class sm {
  class sm::dependencies {
    package {
      "build-essential": ensure => installed;
      "curl": ensure => installed;
      "git-core": ensure => installed;
    }
  }

  include sm::dependencies

  exec { "sm-install":
    alias   => 'sm',
    cwd     => "/tmp",
    path    => '/usr/bin:/usr/sbin:/bin:/opt/sm/bin',
    unless  => 'which sm',
    command => 'curl -L https://github.com/sm/sm/tarball/master -o sm-head.tar.gz &&
    tar zxf sm-head.tar.gz &&
    mv sm-sm-* sm-head &&
    cd sm-head &&
    ./install',
    require => Class['sm::dependencies'], 
  }
  Class["sm"] -> Package<| provider == sm |>
}
