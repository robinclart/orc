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

    def number
      @attributes["number"]
    end
  end
end
