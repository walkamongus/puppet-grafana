require 'spec_helper'

provider_class = Puppet::Type.type(:package).provider(:grafana)

describe provider_class do
  before(:each) do
    @resource = stub 'resource'
    @resource.stubs(:[]).returns(nil)
    @resource.stubs(:[]).with(:name).returns 'mypackage'
    @resource.stubs(:[]).with(:ensure).returns :installed
    @resource.stubs(:command).with(:cli).returns '/sbin/grafana-cli'

    @provider = provider_class.new(@resource)
  end

  it 'should have an install method' do
    @provider = provider_class.new
    expect(@provider).to respond_to(:install)
  end

  it 'should have an uninstall method' do
    @provider = provider_class.new
    expect(@provider).to respond_to(:uninstall)
  end

  it 'should have an update method' do
    @provider = provider_class.new
    expect(@provider).to respond_to(:update)
  end

  it 'should have an latest method' do
    @provider = provider_class.new
    expect(@provider).to respond_to(:latest)
  end

  it 'should use a command-line without versioned package' do
    @resource.stubs(:should).with(:ensure).returns :latest
    @provider.expects(:cli).with('plugins', 'install', 'mypackage')
    @provider.install
  end

  it 'should call install method of instance' do
    @provider.expects(:update)
    @provider.update
  end

  describe 'when getting latest version' do
    context 'when the package has available update' do
      it 'should return a version string' do
        fake_data = File.read(my_fixture('grafana-cli-plugins-list-remote'))
        @resource.stubs(:[]).with(:name).returns 'grafana-piechart-panel'
        described_class.expects(:cli).with('plugins', 'list-remote').returns fake_data
        expect(@provider.latest).to eq('1.1.1')
      end
    end

    context 'when there are no updates available' do
      it 'should return nil' do
        fake_data_empty = File.read(my_fixture('grafana-cli-plugins-list-remote-empty'))
        @resource.stubs(:[]).with(:name).returns 'grafana-piechart-panel'
        described_class.expects(:cli).with('plugins', 'list-remote').returns fake_data_empty
        expect(@provider.latest).to eq(nil)
      end
    end
  end

  it 'should call uninstall method of instance' do
    @provider.expects(:uninstall)
    @provider.uninstall
  end
end
