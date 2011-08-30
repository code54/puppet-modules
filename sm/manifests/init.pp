class sm {
  class sm::dependencies {
    package {
      "build-essential": ensure => installed;
      "curl": ensure => installed;
    }
  }

  include sm::dependencies

  exec { "sm-install":
    alias   => 'sm',
    cwd     => "/tmp",
    path    => '/usr/bin:/usr/sbin:/bin',
    unless  => 'which sm',
    command => 'bash -c "version=`curl https://bdsm.beginrescueend.com/releases/latest.txt` &&
              echo \"Version: \$version\" &&
              curl -O https://sm.beginrescueend.com/releases/sm-\${version}.tar.bz2 &&
              tar jxf sm-\${version}.tar.bz2 &&
              cd sm-\${version} && ./install"',
    require => Class['sm::dependencies'], 
  }

}
