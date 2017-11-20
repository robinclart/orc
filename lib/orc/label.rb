module Orc
  class Label
    def initialize(attributes)
      @attributes = attributes
    end

    def name
      @attributes["name"]
    end
  end
end