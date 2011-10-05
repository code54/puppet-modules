require 'puppet/provider/package/gem'
require 'puppet/util/execution'
Puppet::Type.type(:package).provide :rvm_gem, :parent => Puppet::Type.type(:package).provider(:gem) do

  def self.instances(gemset = false)
    gems = []
    all_rvm_gemsets do |rvm_gemset|
      gemlist(:local => true).collect do |hash|
        hash[:name] = "#{rvm_gemset}:#{hash[:name]}"
        gems << new(hash)
      end
    end
    gems
  end

  def self.all_rvm_gemsets
    if FileTest.file? "/usr/local/rvm/bin/rvm" and FileTest.executable? "/usr/local/rvm/bin/rvm"
      output = execute ["/usr/local/rvm/bin/rvm list gemsets | tail -n -3 | sed 's/=>/  /g' | cut -d ' ' -f 4 | grep -v ^$"]
      gemsets = output.split("\n")
      gemsets.each do |gemset|
        unless gemset.strip.empty?
          rvm_hack_command(gemset) { yield(gemset) }
        end
      end
    else
      []
    end
  end

  def self.rvm_hack_command(rvm_gemset)
    ruby_version, gemset = rvm_gemset.split('@')
    Puppet::Util::Execution.withenv(
    "PATH" => "/usr/local/rvm/gems/#{rvm_gemset}/bin:/usr/local/rvm/rubies/#{ruby_version}/bin:#{ENV['PATH']}",
    "GEM_HOME" => "/usr/local/rvm/gems/#{rvm_gemset}",
    "GEM_PATH" => "/usr/local/rvm/gems/#{rvm_gemset}:/usr/local/rvm/gems/#{rvm_gemset}",
    "MY_RUBY_HOME" => "/usr/local/rvm/rubies/#{ruby_version}",
    "IRBRC" => "/usr/local/rvm/rubies/#{ruby_version}/.irbrc",
    "RUBYOPT" => "",
    "gemset" => "#{gemset}"
    ) { yield }
  end

  def install(useversion = true)
    rvm_gemset, name = split_gemset(resource[:name])
    resource[:name] = name
    self.class.rvm_hack_command(rvm_gemset) do
      super
    end
  end

  def split_gemset(string)
    string.split(':')
  end

end