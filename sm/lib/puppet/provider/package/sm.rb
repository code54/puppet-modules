# Puppet package provider for BDSM
# <http://bdsm.beginrescueend.com>

require 'puppet/provider/package'

Puppet::Type.type(:package).provide :sm,
  :parent => ::Puppet::Provider::Package do

  desc "BDSM S{cripting,ystem,tack} Management (SM) Framework package provider"

  has_feature :installable, :uninstallable, :versionable

  # Return an array of structured information about every installed package
  # that's managed by `sm` or an empty array if `sm` is not available.
  def self.instances
    sm_cmd = which('sm') or return []

    packages = []
    execpipe "#{sm_cmd} sets | grep '^\w' | grep -v -E 'exts/active|core' | cut -d ':' -f 1" do |process|
      process.each do |line|
        packages << new(:name => line.strip, :provider => name)
      end
    end
    packages
  end

  # Return structured information about a particular ruby version or `nil` if
  # it is not installed or `sm` itself is not available.
  def query
    self.class.instances.any? do |provider_sm|
      provider_sm.properties if @resource[:name] == provider_sm.name
    end || nil
  end

  def install
    lazy_sm 'sets install', @resource[:name]
  end

  def uninstall
    lazy_sm "sets uninstall", @resource[:name]
  end

  # Execute a `sm` command.  If Puppet doesn't yet know how to do so,
  # try to teach it and if even that fails, raise the error.
  private

  def lazy_sm(*args)
    sm *args
  rescue NoMethodError
    # TODO Fix, should not use full path, but if removed, first setup won't find it because it's not on the PATH
    raise unless pathname = which('/opt/sm/bin/sm')

    self.class.commands :sm => pathname
    sm *args
  end

end
