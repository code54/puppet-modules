
group {puppet:
  ensure => present,
}

package {
  htop: ensure => installed;
}

# Not necessary if you use sm::user
include sm

# Ok, initialize a user with sm configuration (eg. for deplo)
class {'sm::user':
  username => 'user1',
}