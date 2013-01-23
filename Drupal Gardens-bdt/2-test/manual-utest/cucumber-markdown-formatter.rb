# require 'cucumber/formatter/pretty'
module Markdown
  class Formatter

    def before_feature
      puts ""
    end

    def initialize(step_mother, io, options)
      puts "init"
    end

    def step_name(keyword, step_match, status, source_indent, background)
      puts keyword
    end
  end
end
