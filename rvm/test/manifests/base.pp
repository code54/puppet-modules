
group {puppet:
  ensure => present,
}

package {
  htop: ensure => installed;
}

include rvm

package {"ruby-1.9.2-p290":
  provider => rvm,
}