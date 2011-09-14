
group {puppet:
  ensure => present,
}

package {
  htop: ensure => installed;
}

include sm

package {"ruby":
  provider => 'sm',
}

# # Ok, initialize a user with sm configuration (eg. for deplo)
# class {'sm::user':
#   username => 'user1',
# }
