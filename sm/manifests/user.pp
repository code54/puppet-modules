class sm::user ($username) {

  include sm

  user {"$username":
    ensure     => present,
    shell      => '/bin/bash',
    managehome => true,
  }

  exec {"echo $HOME":
    command => "/opt/sm/bin/sm smrc",
    path    => ["/bin", "/usr/bin"],
    cwd     => "/home/$username",
    creates => "/home/$username/.smrc",
    user    => "$username",
    environment => ["HOME=/home/$username", "USER=$username"],
    logoutput => true,
    require => [User["$username"], Exec['sm-install']],
  }

}