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
      @hinters.each_with_object("#{pretty_global}\n\nid   #{magenta("total")}\t#{bold("sql")}\t\t#{cyan("ruby")}\n") do |(code, hinter), str|
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

    def sql_rate  
      (global_time == 0 ? 0 : (sql_time * 100 / global_time)).round(@options[:round_time])
    end

    def ruby_rate
      (100 - sql_rate).round(@options[:round_time])
    end

    def sql_call
      @hinters.sum{ |code, hinter| hinter.metrics.sql_call }
    end

    def global_time
      @hinters.sum{ |code, hinter| hinter.metrics.global_time_rounded }.round(@options[:round_time])
    end

    def sql_time
      @hinters.sum{ |code, hinter| hinter.metrics.sql_time_rounded }.round(@options[:round_time])
    end

    def ruby_time
      @hinters.sum{ |code, hinter| hinter.metrics.ruby_time_rounded }.round(@options[:round_time])
    end

    private

    def pretty_global
      global = "global: #{global_time}s"
      sql = "sql: #{sql_rate}% (#{sql_time}s, #{sql_call}⚡)"
      ruby ="ruby: #{ruby_rate}% (#{ruby_time}s)"
  
      "#{magenta(global)}\t#{bold(sql)}\t#{cyan(ruby)}"
    end
  end
end