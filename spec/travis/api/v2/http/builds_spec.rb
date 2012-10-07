require 'spec_helper'

describe Travis::Api::V2::Http::Builds do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V2::Http::Builds.new([build]).data }

  it 'builds' do
    data['builds'].first.should == {
      'id' => 1,
      'repository_id' => 1,
      'commit_id' => 1,
      'job_ids' => [1, 2],
      'number' => 2,
      'pull_request' => false,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'state' => 'finished',
      'result' => 0,
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => 60
    }
  end

  it 'commit' do
    data['commits'].first.should == {
      'id' => commit.id,
      'sha' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
    }
  end
end

describe 'Travis::Api::V2::Http::Builds using Travis::Services::Builds::All' do
  include Support::ActiveRecord

  let!(:repo)  { Factory(:repository) }
  let(:builds) { Travis::Services::Builds::All.new(nil, :event_type => 'push', :repository_id => repo.id).run }
  let(:data)   { Travis::Api::V2::Http::Builds.new(builds).data }

  before :each do
    3.times { Factory(:build, :repository => repo) }
  end

  it 'queries' do
    lambda { data }.should issue_queries(5)
  end
end

