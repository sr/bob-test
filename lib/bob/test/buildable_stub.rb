module Bob::Test
  BuildableStub = Struct.new(:kind, :uri, :branch, :build_script) do
    include Bob::Buildable

    attr_reader :repo, :builds, :metadata

    def self.from(repo)
      kind = repo.class == Bob::Test::GitRepo ? :git : :svn
      # same
      uri =
        if kind == :git
          repo.path
        else
          "file://#{SvnRepo.server_root}/#{repo.name}"
        end
      # move to repo
      branch = (kind == :git) ? "master" : ""
      build_script = "./test"

      new(kind, uri, branch, build_script)
    end

    def initialize(*args)
      super

      @builds   = {}
      @metadata = {}
    end

    def start_building(commit_id, commit_info)
      @metadata[commit_id] = commit_info
    end

    def finish_building(commit_id, status, output)
      @builds[commit_id] = [status ? :successful : :failed, output]
    end
  end
end
