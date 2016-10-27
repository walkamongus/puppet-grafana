require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:grafana, :parent => ::Puppet::Provider::Package) do

  desc "Grafana plugins via `grafana-cli`."

  has_feature :installable, :uninstallable, :upgradeable, :versionable

  commands :cli => 'grafana-cli'

  def self.current_version
    return @current_version unless @current_version.nil?
    output = cli '--version'
    @current_version = output.gsub('Grafana cli version ', '').strip
  end

  def self.parse(line)
    if line.chomp =~ /^([^ ]+) @ ([^ ]+) *$/
      {:ensure => $2, :name => $1, :provider => name}
    else
      nil
    end
  end

  def self.instances
    packages = []

    begin
      execpipe("#{command(:cli)} plugins ls") do |process|
        process.each_line do |line|
          next unless hash = parse(line)
          packages << new(hash)
        end
      end
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, "Failed to list packages", $!.backtrace
    end

    packages
  end

  def query
    self.class.instances.each do |provider_grafana|
      return provider_grafana.properties if @resource[:name].downcase == provider_grafana.name.downcase
    end
    return nil
  end

  def install
    cli 'plugins', 'install', @resource[:name]
  end

  def latest
    output = cli 'plugins', 'list-remote'

    if output =~ /id: #{Regexp.escape @resource[:name]} version: ([^ ]+) *$/
      return $1
    else
      return @property_hash[:ensure]
    end
  end

  def uninstall
    cli 'plugins', 'uninstall', @resource[:name]
  end

  def update
    if @property_hash[:ensure] == :absent
      install
    else
      cli 'plugins', 'update', @resource[:name]
    end
  end
end
