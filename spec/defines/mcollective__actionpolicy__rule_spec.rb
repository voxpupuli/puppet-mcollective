require 'spec_helper'

describe 'mcollective::actionpolicy::rule', type: :define do
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
  context 'default-puppet' do
    let(:title) { 'default-puppet' }
    let(:params) do
      {
        agent: 'puppet'
      }
    end

    it do
      is_expected.to contain_datacat_fragment('mcollective::actionpolicy::rule default-puppet'). \
        with_target('mcollective::actionpolicy puppet'). \
        with_data('lines' => [
                    {
                      'action'   => 'allow',
                      'callerid' => '*',
                      'actions'  => '*',
                      'facts'    => '*',
                      'classes'  => '*'
                    }
                  ])
    end
  end

  context 'facts-specified' do
    let(:title) { 'default-puppet' }
    let(:params) do
      {
        agent: 'puppet',
        fact_filter: 'environment=dev and !customer=acme'
      }
    end

    it do
      is_expected.to contain_datacat_fragment('mcollective::actionpolicy::rule default-puppet'). \
        with_target('mcollective::actionpolicy puppet'). \
        with_data('lines' => [
                    {
                      'action'   => 'allow',
                      'callerid' => '*',
                      'actions'  => '*',
                      'facts'    => 'environment=dev and !customer=acme',
                      'classes'  => '*'
                    }
                  ])
    end
  end
end
