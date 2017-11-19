module Orc
  class Client
    REL_RX  = %r/rel="(.*?)"/
    PAGE_RX = %r/page=(\d)/

    def initialize(namespace)
      @namespace = namespace
      @config    = YAML.load_file(".orc/config.yml")
    end

    def fatal(code)
      error = File.read(File.join(ROOT, "errors", "#{code}"))
      $stderr.write error
      $stderr.puts "error: #{code}"

      exit 1
    end

    def open_editor(template:, append: nil, remove_comments: true)
      source = File.read(File.join(Orc::ROOT, "templates", template.to_s))

      File.open(".orc/#{template}", "w+") do |f|
        f.write(source)
        if append
          f.puts
          f.puts append.strip
        end
      end

      system("#{ENV["EDITOR"]} .orc/#{template}")

      content = File.read(".orc/#{template}").strip

      if remove_comments
        lines   = content.each_line.to_a
        content = lines.select { |l| l.chars[0] != "#" }.join.strip
      end

      FileUtils.rm(".orc/PULL_REQUEST")

      if content == ""
        return nil
      end

      content + "\n"
    end

    def add_labels(number:, labels: [])
      uri = issues_uri
      uri.path = uri.path + "/#{number}/labels"

      response = Typhoeus::Request.new(uri.to_s, {
        method: :post,
        body: JSON.generate(labels),
        headers: {
          "Content-Type"  => "application/json",
          "Accept"        => "application/vnd.github.v3+json",
          "Authorization" => "token #{token}",
        },
      }).run
    end

    def create_pull_request(params = {})
      pr = find_first_pull_request_by_head(params[:head])

      if pr
        return pr
      end

      params[:base] ||= repo_base

      response = Typhoeus::Request.new(pulls_uri.to_s, {
        method: :post,
        body: JSON.generate(params),
        headers: {
          "Content-Type"  => "application/json",
          "Accept"        => "application/vnd.github.v3+json",
          "Authorization" => "token #{token}",
        },
      }).run

      attributes = JSON.parse(response.body)

      if attributes["errors"]
        errors = attributes["errors"]

        if errors.first["field"] == "base" && errors.first["code"] == "invalid"
          fatal(:invalid_base_branch_for_pr)
        else
          $stderr.puts(response.body.strip)
          fatal(:create_pr_github_error)
        end
      end

      PullRequest.new(attributes)
    end

    def find_first_pull_request_by_head(head_branch)
      uri = pulls_uri
      uri.query = URI.encode_www_form({
        state: "open",
        head:  "#{head_user}:#{head_branch}",
      })

      response = Typhoeus::Request.new(uri.to_s, {
        method: :get,
        headers: {
          "Accept"        => "application/vnd.github.v3+json",
          "Authorization" => "token #{token}",
        },
      }).run

      attributes = JSON.parse(response.body).first

      if attributes
        PullRequest.new(attributes)
      end
    end

    def find_pull_request(number)
      uri = pulls_uri
      uri.path = uri.path + "/#{number}"

      response = Typhoeus::Request.new(uri.to_s, {
        method: :get,
        headers: {
          "Accept"        => "application/vnd.github.v3+json",
          "Authorization" => "token #{token}",
        },
      }).run

      attributes = JSON.parse(response.body)

      if attributes
        PullRequest.new(attributes)
      end
    end


    def search_pull_requests(query = "")
      result = []
      page   = 1
      query  = [query, "is:pr", "repo:#{repo_name}"].join(" ")

      loop do
        uri = search_uri
        uri.query = URI.encode_www_form(q: query, page: page)

        response = Typhoeus::Request.new(uri.to_s, {
          method: :get,
          headers: {
            "Accept"        => "application/vnd.github.v3+json",
            "Authorization" => "token #{token}",
          },
        }).run

        prs   = parse_prs(response.body)
        links = parse_links(response.headers["Link"])

        result += prs

        if links[:next].nil?
          break
        end

        page = links[:next]
      end

      result
    end

    private

    def head_user
      repo_name.split("/").first
    end

    def repo_name
      @config["repo"]["name"]
    end

    def token
      @config["core"]["token"]
    end

    def url
      @config["core"]["url"]
    end

    def repo_base
      @config["repo"]["base"]
    end

    def search_uri
      uri = URI.parse(url)
      uri.path = uri.path + "/search/issues"
      uri
    end

    def pulls_uri
      uri = URI.parse(url)
      uri.path = uri.path + "/repos/#{repo_name}/pulls"
      uri
    end

    def issues_uri
      uri = URI.parse(url)
      uri.path = uri.path + "/repos/#{repo_name}/issues"
      uri
    end

    def parse_prs(source)
      JSON.parse(source)["items"].map { |a| PullRequest.new(a) }
    end

    def parse_links(header)
      if header.nil?
        return {}
      end

      links = header.split(",").map do |link|
        [
          link.match(REL_RX)[1].to_sym,
          link.match(PAGE_RX)[1].to_i,
        ]
      end

      links = Hash[links]
    end
  end
end
