module Hinters
  module Print
    def pretty_rate(data)
      str = "#{data[:rate_time]}% (total: #{data[:total_time]}s, #{pretty_call(data[:nb_call])})"

      if data[:total_time] > @critical_time
        str.red
      elsif data[:total_time] > @warning_time
        str.yellow
      else
        str
      end
    end

    def pretty_call(nb_call)
      "#{nb_call} #{nb_call > 1 ? "queries" : "query"}"
    end

    def top_query
      top_queries(1)
    end

    def top_queries(limit = 1)
      str_queries = []

      @queries.first(limit).each do |query|
        str_query = "#{query[:file_name]}:#{query[:line]} ".cyan
        str_query += "\e[3m#{"#{query[:code]}"}\e[23m\n"
        str_query += "#{"\e[1m(#{query[:time].round(@round_time)}s)\e[22m "} #{query[:sql].gray}\n"
        str_queries << str_query
      end

      puts str_queries.join("\n")
    end
  end
end