module Helpers
  module Print
    def refresh_pretty!
      @pretty = "#{pretty_global}\n"

      @metrics.files.keys.each do |file|
        @pretty << "#{file.to_s.cyan}\n"
  
        @metrics.files[file].each do |line, data|
          @pretty << "##{line}\t#{pretty_rate(data)}\t#{italic_gray(data[:code])}\n"
        end
  
        @pretty << "\n"
      end
    end

    def pretty_global(short: false)
      global = short ? "#{@metrics.global_time_rounded}s" : "global: #{@metrics.global_time_rounded}s"
      sql = short ? "#{@metrics.sql_time_rounded}s (#{@metrics.global_sql_call}⚡)" : "sql: #{@metrics.sql_rate_rounded}% (#{@metrics.sql_time_rounded}s, #{@metrics.global_sql_call}⚡)"
      ruby = short ? "#{@metrics.ruby_time_rounded}s" : "ruby: #{@metrics.ruby_rate_rounded}% (#{@metrics.ruby_time_rounded}s)"
  
      "#{magenta(global)}\t#{bold(sql)}\t#{cyan(ruby)}"
    end

    def pretty_rate(data)
      total_section = "sql: #{data[:total_time]}s"

      total_section = if data[:total_time] > @options[:critical_time]
        red(total_section)
      elsif data[:total_time] > @options[:warning_time]
        yellow(total_section)
      else
        total_section
      end

      "#{data[:rate_time]}% (#{total_section}, #{pretty_call(data[:nb_call])})"
    end

    def pretty_call(nb_call)
      call_section = "#{nb_call}#{nb_call > 1 ? "⚡" : "⚡"}"

      call_section = if nb_call > @options[:critical_sql_call]
        red(call_section)
      elsif nb_call > @options[:warning_sql_call]
        yellow(call_section)
      else
        call_section
      end

      call_section
    end

    def top_query
      top_queries(1)
    end

    def top_queries(limit = 1)
      str_queries = []

      @metrics.queries.first(limit).each do |query|
        str_query = cyan("#{query[:file_name]}:#{query[:line]} \n")
        str_query += italic("#{query[:code]}\n")
        str_query += "(#{bold("#{query[:time].round(@options[:round_time])}s")}) #{gray(query[:sql])}\n"
        str_queries << str_query
      end

      puts str_queries.join("\n")
    end
  end
end