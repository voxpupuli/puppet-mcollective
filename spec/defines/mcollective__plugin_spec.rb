require 'spec_helper'

describe 'mcollective::plugin' do
  let :facts do
    {
      puppetversion: Puppet.version,
      facterversion: Facter.version,
      macaddress: '00:00:00:26:28:8a',
      osfamily: 'RedHat',
      operatingsystem: 'CentOS',
      mco_version: '2.8.4',
      path: ['/usr/bin', '/usr/sbin']
    }
  end
  let(:title) { 'fishcakes' }
  context '#source' do
    context 'default (unset)' do
      it { is_expected.to contain_datacat_fragment('mcollective::plugin fishcakes') }
      it { is_expected.to contain_datacat_fragment('mcollective::plugin fishcakes').with_target('mcollective::site_libdir') }
      it { is_expected.to contain_datacat_fragment('mcollective::plugin fishcakes').with_data('source_path' => ['puppet:///modules/mcollective/plugins/fishcakes']) }
    end

    context 'set' do
      let(:params) { { source: 'puppet:///modules/my_module/fishcakes' } }
      it { is_expected.to contain_datacat_fragment('mcollective::plugin fishcakes') }
      it { is_expected.to contain_datacat_fragment('mcollective::plugin fishcakes').with_target('mcollective::site_libdir') }
      it { is_expected.to contain_datacat_fragment('mcollective::plugin fishcakes').with_data('source_path' => ['puppet:///modules/my_module/fishcakes']) }
    end
  end

  context '#package' do
    context 'default (false)' do
      it { is_expected.not_to contain_package('mcollective-fishcakes-agent') }
      it { is_expected.not_to contain_package('mcollective-fishcakes-client') }
    end

    context 'true' do
      let(:params) { { package: true } }
      it { is_expected.to contain_package('mcollective-fishcakes-agent') }

      context '#client' do
        context 'default (false)' do
          it { is_expected.not_to contain_package('mcollective-fishcakes-client') }
        end

        context 'true' do
          let(:params) { { package: true, client: true } }
          it { is_expected.to contain_package('mcollective-fishcakes-client') }
        end
      end
    end
  end
end
