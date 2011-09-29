
group {puppet:
  ensure => present,
}

package {
  htop: ensure => installed;
}

include rvm

user {deploy:
  ensure     => present,
  shell      => '/bin/bash',
  home       => '/home/deploy',
  managehome => true,
  require    => [Group[puppet]],
}

rvm::user {'rvm::user::deploy': user => 'deploy', }

package {"ruby-1.9.2-p290":
  provider => rvm,
}