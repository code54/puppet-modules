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

# Installing passenger apache!
package {'passenger_apache_dependencies':
  name => ['apache2','apache2-prefork-dev','libapr1-dev','libaprutil1-dev','libcurl4-openssl-dev'],
  # require => Exec['apt-update'],
}

class {"rvm::passenger::apache":
  ruby => 'ruby-1.9.2-p290',
  require => Package['passenger_apache_dependencies'],
}

exec {"apt-update":
  command => '/usr/bin/apt-get update',
  onlyif  => "/bin/sh -c 'uptime | grep -qE \"min|sec\" || [ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
}
Exec['apt-update'] -> Package<| provider == apt |>
