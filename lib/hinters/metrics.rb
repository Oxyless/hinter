module Hinters
  class Metrics
    attr_accessor :global_time, :global_sql_time, :global_sql_call, :files, :queries

    def initialize(round_time: 2)
      @queries = []

      @global_time = 0
      @global_sql_time = 0 
      @global_sql_call = 0 
      @files = {}
      @pretty = ""

      @round_time = round_time
    end

    def sql_rate_rounded
      (@global_time == 0 ? 0 : (@global_sql_time * 100 / @global_time).round(@round_time))
    end

    def ruby_rate_rounded
      (100 - sql_rate_rounded).round(@round_time)
    end

    def global_time_rounded
      @global_time.round(@round_time)
    end

    def sql_time_rounded
      @global_sql_time.round(@round_time)
    end

    def ruby_time_rounded
      (global_time_rounded - sql_time_rounded).round(@round_time)
    end

    def enrich_data!
      @queries = @queries.sort_by{|query| query[:time] }.reverse
  
      @files.keys.each do |file|
        @files[file] = @files[file].sort_by{|line, data| data[:total_time] }.reverse.to_h
  
        file_content = cached_file_content(file)
  
        @files[file].each do |line, data|
          data[:file] = file
          data[:queries] = data[:queries].sort_by{|query| query[:time] }.reverse
          data[:rate_time] = (data[:total_time] * 100 / @global_sql_time).to_f.round(2)
          data[:total_time] =  data[:total_time].to_f.round(@round_time)
          data[:code] = (file_content ? file_content.lines[line - 1].strip : '-')
        end
      end
  
      @files = @files.sort_by do |file, lines|
        lines.values.map{ |value| value[:total_time] } || 0
      end.reverse.to_h
    end

    def cached_file_content(file)
      @cached_file_content_ ||= {}
      @cached_file_content_[file] ||= File.read(file.to_s) rescue "-"
      @cached_file_content_[file]
    end
  end
end