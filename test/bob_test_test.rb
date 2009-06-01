require "test/unit"
require "bob/test"

class BobTestTest < Test::Unit::TestCase
  include Bob::Test

  def assert_scm_repo(repo)
    repo.destroy
    repo.create

    assert_equal 1, repo.commits.size
    assert_equal "First commit", repo.commits.first[:message]

    repo.add_failing_commit
    assert_equal 2, repo.commits.size
    assert_equal "This commit will fail", repo.commits.last[:message]
    assert_equal repo.commits.last[:identifier], repo.head
    assert repo.short_head

    repo.add_successful_commit
    assert_equal 3, repo.commits.size
    assert_equal "This commit will work", repo.commits.last[:message]
    assert_equal repo.commits.last[:identifier], repo.head
  end

  def test_buildable_stub
    b = BuildableStub.new(:git, "git://github.com/ry/node", "master", "make")

    assert_equal :git,                       b.kind
    assert_equal "git://github.com/ry/node", b.uri
    assert_equal "master",                   b.branch
    assert_equal "make",                     b.build_script
  end

  def test_scm_repo
    assert_scm_repo(GitRepo.new(:my_test_project))
    assert_scm_repo(SvnRepo.new(:my_test_project))
  end

  def test_buildable_git_repo
    Bob.directory = "/tmp/bob-git"

    repo = GitRepo.new(:test_repo)
    repo.destroy
    repo.create

    b = BuildableStub.from(repo)
    assert_equal :git,                     b.kind
    assert_equal "/tmp/bob-git/test_repo", b.uri
    assert_equal "master",                 b.branch
    assert_equal "./test",                 b.build_script
  end

  def test_buildable_svn_repo
    Bob.directory = "/tmp/bob-svn"

    repo = SvnRepo.new(:test_repo)
    repo.destroy
    repo.create

    b = BuildableStub.from(repo)
    assert_equal :svn,      b.kind
    assert_equal "",        b.branch
    assert_equal "./test",  b.build_script
    assert_equal "file:///tmp/bob-svn/svn/test_repo", b.uri
  end
end
