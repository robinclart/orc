require "uri"
require "typhoeus"
require "json"
require "yaml"
require "fileutils"

module Orc
  class Client
    ROOT = File.expand_path("../", __dir__)

    def initialize(namespace)
      @namespace = namespace
      @config    = YAML.load_file(".orc/config.yml")
    end

    def fatal(code)
      error = File.read(File.join(ROOT, "errors", "#{code}"))
      $stderr.write error

      exit 1
    end

    def open_editor(template:, append: nil, remove_comments: true)
      source = File.read(File.join(ROOT, "templates", template.to_s))

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

    def search_all_pull_requests(query = nil)
      prs  = []
      page = 1

      loop do
        response = search_pull_requests(q: query, page: page)

        prs += response.prs

        if response.links["next"].nil?
          break
        end

        page = response.links["next"]
      end

      prs
    end

    private

    def search_pull_requests(params = {})
      params[:q] ||= ""
      params[:q] = [
        params[:q],
        "is:pr",
        "repo:#{repo_name}"
      ].join(" ")

      uri = search_uri
      uri.query = URI.encode_www_form(params)

      request = Typhoeus::Request.new(uri.to_s, {
        method: :get,
        headers: {
          "Content-Type"  => "application/json",
          "Accept"        => "application/vnd.github.v3+json",
          "Authorization" => "token #{token}",
        },
      })

      response = request.run

      SearchPullRequestsResponse.new(response)
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

    def search_uri
      uri = URI.parse(url)
      uri.path = "/api/v3/search/issues"
      uri
    end
  end

  class SearchPullRequestsResponse
    REL_RX  = %r/rel="(.*?)"/
    PAGE_RX = %r/page=(\d)/

    def initialize(response)
      @prs   = parse_prs(response.body)
      @links = parse_links(response.headers["Link"])
    end

    def prs
      @prs
    end

    def links
      @links
    end

    private

    def parse_prs(source)
      JSON.parse(source)["items"].map { |a| PullRequest.new(a) }
    end

    def parse_links(header)
      if header.nil?
        return {}
      end

      links = header.split(",").map do |link|
        [
          link.match(REL_RX)[1],
          link.match(PAGE_RX)[1].to_i,
        ]
      end

      links = Hash[links]
    end
  end

  class PullRequest
    def initialize(attributes)
      @attributes = attributes
    end

    def username
      @attributes["user"]["login"]
    end

    def title
      @attributes["title"]
    end

    def number
      @attributes["number"]
    end
  end
end
