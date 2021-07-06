require_relative "../helpers/color"

module Hinters
  class List
    attr_accessor :hinters

    include Helpers::Color
    
    def initialize(options)
      @hinters = {}
      @options = options
    end

    def expand(hinter_id)
      hinter_id = hinter_id.gsub("#", "").to_i if hinter_id.is_a?(String)
      code = @hinters.keys[hinter_id - 1]

      if code
        @hinters[code]
      end
    end

    def slow(tot_min = 1)
      puts self.inspect(tot_min: tot_min)
    end

    def inspect(tot_min: 0, sql_min: 0, sql_call: 0, ruby_min: 0)
      hidx = 1
      @hinters.each_with_object("id   #{magenta("total")}\t#{bold("sql")}\t\t#{cyan("ruby")}\n") do |(code, hinter), str|
        if (hinter.metrics.global_time >= tot_min && 
            hinter.metrics.global_sql_time >= sql_min && 
            hinter.metrics.global_sql_call >= sql_call && 
            hinter.metrics.ruby_time_rounded >= ruby_min)
          pretty_index = (hidx < 10 ? "#{hidx}   " : (hidx < 100 ? "#{hidx}  " : hidx))
        
          code_decorated = code.split("\n").map.with_index { |line, idx|
            "#{idx > 0 ? "\t\t\t\t" : "##{pretty_index}#{hinter.pretty_global(short: true)}"}\t#{line}"
          }.join("\n")

          str << "#{code_decorated}\n"
        end
        hidx += 1
        str
      end
    end
  end
end