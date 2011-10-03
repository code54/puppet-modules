
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
  provider => 'rvm',
}

package {"ruby-1.9.2-p290@global:irbtools":
  provider => 'rvm_gem',
  require => Package['ruby-1.9.2-p290']
}

rvm::gemset {"Test gemset":
 ruby => 'ruby-1.9.2-p290', gemset => 'onegemset',
}