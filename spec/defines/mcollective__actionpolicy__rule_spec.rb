require 'spec_helper'

describe 'mcollective::actionpolicy::rule', :type => :define do
  context 'default-puppet' do
    let(:title) { 'default-puppet' }
    let(:params) do
      {
        :agent => 'puppet',
      }
    end

    it {
      should contain_datacat_fragment('mcollective::actionpolicy::rule default-puppet') \
        .with_target('mcollective::actionpolicy puppet') \
        .with_data({
          'lines' => [
            {
              'action'   => 'allow',
              'callerid' => '*',
              'actions'  => '*',
              'facts'    => '*',
              'classes'  => '*',
            },
          ],
        })
      }
  end

  context 'facts-specified' do
    let(:title) { 'default-puppet' }
    let(:params) do
      {
        :agent       => 'puppet',
        :fact_filter => 'environment=dev and !customer=acme',
      }
    end

    it {
      should contain_datacat_fragment('mcollective::actionpolicy::rule default-puppet') \
        .with_target('mcollective::actionpolicy puppet') \
        .with_data({
          'lines' => [
            {
              'action'   => 'allow',
              'callerid' => '*',
              'actions'  => '*',
              'facts'    => 'environment=dev and !customer=acme',
              'classes'  => '*',
            },
          ],
        })
      }
  end
end
