require 'spec_helper'

describe 'grafana' do
  let(:params) do
    {
      :admin_password => 'admin',
      :secret_key     => 'abc123'
    }
  end

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile }.to raise_error(/not supported on an Unsupported/) }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}", :compile do
      let(:facts) do
        facts
      end

      it { should contain_class('grafana') }
      it { should contain_class('grafana::params') }
      it { should contain_class('grafana::install').that_comes_before('Class[grafana::config]') }
      it { should contain_class('grafana::config').that_notifies('Class[grafana::service]') }
      it { should contain_class('grafana::service') }
      it { should contain_file('/etc/grafana') }
      it { should contain_file('/etc/grafana/grafana.ini') }
      it { should contain_file('/var/lib/grafana') }
      it { should contain_file('/var/lib/grafana/plugins') }
      it { should contain_file('/var/log/grafana') }
      it { should contain_grafana_ini_setting('analytics/check_for_updates').with_value('true') }
      it { should contain_grafana_ini_setting('grafana_net/url').with_value('https://grafana.net') }
      it { should contain_grafana_ini_setting('paths/data').with_value('/var/lib/grafana') }
      it { should contain_grafana_ini_setting('paths/logs').with_value('/var/log/grafana') }
      it { should contain_grafana_ini_setting('paths/plugins').with_value('/var/lib/grafana/plugins') }
      it { should contain_grafana_ini_setting('security/admin_password').with_value('admin') }
      it { should contain_grafana_ini_setting('security/admin_user').with_value('admin') }
      it { should contain_grafana_ini_setting('security/secret_key').with_value('abc123') }
      it { should contain_group('grafana') }
      it { should contain_package('grafana') }
      it { should contain_resources('grafana_ini_setting') }
      it { should contain_service('grafana-server') }
      it { should contain_user('grafana') }

      case facts[:osfamily]
      when 'RedHat'
        it { should contain_file('/etc/sysconfig/grafana-server') }
        it { should contain_yumrepo('grafana') }
      end

      context 'with a package name and version specified' do
        let(:params) { super().merge(:package_name => 'grafana-server', :package_ensure => '4.1.1') }
        it do
          should contain_package('grafana').with(
            'name'   => 'grafana-server',
            'ensure' => '4.1.1'
          )
        end
      end
    end
  end
end
