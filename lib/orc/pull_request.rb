module Orc
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

    def body
      @attributes["body"]
    end

    def number
      @attributes["number"]
    end

    def html_url
      @attributes["html_url"]
    end
  end
end
