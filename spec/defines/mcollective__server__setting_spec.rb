require 'spec_helper'

describe 'mcollective::server::setting' do
  context 'some_setting' do
    let(:title) { 'some_setting' }
    let(:params) { { 'value' => 'pie' } }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting') }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting').with_setting('some_setting') }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting').with_value('pie') }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting').with_target('mcollective::server') }
  end
end
