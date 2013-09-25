require 'spec_helper'

describe 'mcollective::client::setting' do
  context 'some_setting' do
    let(:title) { 'some_setting' }
    let(:params) { { 'value' => 'pie' } }
    it { should contain_mcollective__setting('mcollective::client::setting some_setting') }
    it { should contain_mcollective__setting('mcollective::client::setting some_setting').with_setting('some_setting') }
    it { should contain_mcollective__setting('mcollective::client::setting some_setting').with_value('pie') }
    it { should contain_mcollective__setting('mcollective::client::setting some_setting').with_target(%w[ mcollective::client mcollective::user ]) }
  end
end
