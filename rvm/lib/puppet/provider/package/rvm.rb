# Puppet package provider for Ruby Version Manager `rvm`.
# <http://rvm.beginrescueend.com>

require 'puppet/provider/package'

Puppet::Type.type(:package).provide :rvm,
  :parent => ::Puppet::Provider::Package do

  desc "Ruby Versions via `rvm`."

  has_feature :installable, :uninstallable, :versionable

  # Return an array of structured information about every installed package
  # that's managed by `rvm` or an empty array if `rvm` is not available.
  def self.instances
    rvm_cmd = which('rvm') or return []

    packages = []
    execpipe "#{rvm_cmd} list strings" do |process|
      process.each do |line|
        packages << new(:name => line.strip, :provider => name)
      end
    end
    packages
  end

  # Return structured information about a particular ruby version or `nil` if
  # it is not installed or `rvm` itself is not available.
  def query
    self.class.instances.any? do |provider_rvm|
      provider_rvm.properties if @resource[:name] == provider_rvm.name
    end || nil
  end

  def install
    lazy_rvm 'install', @resource[:name]
  end

  def uninstall
    lazy_rvm "uninstall", @resource[:name]  end

  # Execute a `rvm` command.  If Puppet doesn't yet know how to do so,
  # try to teach it and if even that fails, raise the error.
  private
  def lazy_rvm(*args)
    rvm *args
  rescue NoMethodError
    # TODO Fix, should not use full path, but if removed, first setup won't find it because it's not on the PATH
    raise unless pathname = which('/usr/local/rvm/bin/rvm')

    self.class.commands :rvm => pathname
    rvm *args
  end

end