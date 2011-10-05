class rvm::passenger::apache(
    $ruby
  ) {

  package {"$ruby@global:passenger":
    provider => 'rvm_gem',
    require => Package[$ruby],
  }

  exec {'passenger-install-apache2-module':
    command   => "rvm $ruby exec passenger-install-apache2-module -a",
    path      => "/usr/local/rvm/bin:/usr/bin:/usr/sbin:/bin",
    # Cut the path for the .so file from the snippet (1st row 3rd field)
    unless    => "test -f \"`rvm $ruby exec passenger-install-apache2-module  --snippet | head -n 1 | cut -f 3 -d ' '`\"",
    logoutput => on_failure,
    require   => Package["$ruby@global:passenger"],
  }

  exec {"generate apache passenger conf":
    command => "/usr/local/rvm/bin/rvm $ruby exec passenger-install-apache2-module --snippet > /etc/apache2/mods-enabled/passenger.conf",
    creates => '/etc/apache2/mods-enabled/passenger.conf',
    require => Package["$ruby@global:passenger"],
  }

}