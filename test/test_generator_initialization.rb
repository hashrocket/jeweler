require 'test_helper'

class TestGeneratorInitialization < Test::Unit::TestCase
  def setup
    @project_name = 'the-perfect-gem'
    @git_name = 'foo'
    @git_email = 'bar@example.com'
    @github_user = 'technicalpickles'
    @github_token = 'zomgtoken'
  end

  def stub_git_config(options = {})
    stub.instance_of(Git::Lib).parse_config('~/.gitconfig') { options }
  end

  context "given a nil github repo name" do
    setup do
      stub_git_config

      @block = lambda {  }
    end

    should 'raise NoGithubRepoNameGiven' do
      assert_raise Jeweler::NoGitHubRepoNameGiven do
        Jeweler::Generator.new(nil)
      end
    end
  end

  context "without git user's name set" do
    setup do
      stub_git_config 'user.email' => @git_email
    end

    should 'raise an NoGitUserName' do
      assert_raise Jeweler::NoGitUserName do
        Jeweler::Generator.new(@project_name)
      end
    end
  end

  context "without git user's email set" do
    setup do
      stub_git_config 'user.name' => @git_name
    end

    should 'raise NoGitUserName' do
      assert_raise Jeweler::NoGitUserEmail do
        Jeweler::Generator.new(@project_name)
      end
    end
  end

  context "without github username set" do
    setup do
      stub_git_config 'user.email' => @git_email, 'user.name' => @git_name
    end

    should 'raise NotGitHubUser' do
      assert_raise Jeweler::NoGitHubUser do
        Jeweler::Generator.new(@project_name)
      end
    end
  end
  
  context "without github token set" do
    setup do
      stub_git_config 'user.name' => @git_name, 'user.email' => @git_email, 'github.user' => @github_user
    end

    should 'raise NoGitHubToken if creating repo' do
      assert_raise Jeweler::NoGitHubToken do
        Jeweler::Generator.new(@project_name, :create_repo => true)
      end
    end
  end
  
  context "with valid git user configuration" do
    setup do
      stub_git_config 'user.name' => @git_name, 'user.email' => @git_email, 'github.user' => @github_user, 'github.token' => @github_token
    end

    context "for technicalpickle's the-perfect-gem repository" do
      setup do
        @generator = Jeweler::Generator.new(@project_name)
      end

      should "assign user's name from git config" do
        assert_equal @git_name, @generator.user_name
      end

      should "assign email from git config" do
        assert_equal @git_email, @generator.user_email
      end

      should "assign github remote" do
        assert_equal 'git@github.com:technicalpickles/the-perfect-gem.git', @generator.git_remote
      end

      should "assign github username from git config" do
        assert_equal @github_user, @generator.github_username
      end

      should "determine project name as the-perfect-gem" do
        assert_equal @project_name, @generator.project_name
      end

      should "determine target directory as the same as the github repository name" do
        assert_equal @generator.project_name, @generator.target_dir
      end
    end
  end
end
