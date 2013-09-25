require 'spec_helper'

describe 'mcollective::user::setting' do
  context 'nagios:some_setting' do
    let(:title) { 'nagios:some_setting' }
    let(:params) { { 'username' => 'nagios', 'value' => 'pie', :setting => 'some_setting' } }
    it { should contain_mcollective__setting('mcollective::user::setting nagios:some_setting') }
    it { should contain_mcollective__setting('mcollective::user::setting nagios:some_setting').with_setting('some_setting') }
    it { should contain_mcollective__setting('mcollective::user::setting nagios:some_setting').with_value('pie') }
    it { should contain_mcollective__setting('mcollective::user::setting nagios:some_setting').with_target('mcollective::user nagios') }
  end
end
