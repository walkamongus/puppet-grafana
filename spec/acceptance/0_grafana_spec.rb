require 'spec_helper_acceptance'

describe 'grafana' do

  it 'should work with no errors' do

    pp = <<-EOS
      class { '::grafana':
        admin_password => 'admin',
        secret_key     => 'abc123',
      }

      ::grafana::plugin { 'grafana-piechart-panel':
        ensure => present,
      }
    EOS

    apply_manifest(pp, :catch_failures => true, :future_parser => true)
    apply_manifest(pp, :catch_changes  => true, :future_parser => true)
  end

  describe package('grafana') do
    it { should be_installed }
  end

  describe service('grafana-server') do
    it { should be_running }
    it { should be_enabled }
  end

  describe file('/etc/grafana/grafana.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'grafana' }
    it { should be_mode 640 }
  end

  describe file('/etc/sysconfig/grafana-server') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
  end

  describe port(3000) do
    it { should be_listening.on('::').with('tcp6') }
  end

  describe command('curl -u admin:admin http://localhost:3000/api/orgs') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq '[{"id":1,"name":"Main Org."}]' }
  end

  describe command('grafana-cli plugins ls') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^grafana-piechart-panel @ [^ ]+ *$/ }
  end
end
