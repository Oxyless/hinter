class Hinter
  def initialize(
    file_pattern: nil,
    warning_time: 1,
    critical_time: 5,
    round_time: 2,
    watch_dir: /\/app\//,
    ignored: /(\/gems\/|\(pry\)|bin\/rails|hinter)/
  )
    @file_pattern = file_pattern
    @warning_time = warning_time
    @critical_time = critical_time
    @round_time = round_time
    @watch_dir = watch_dir
    @ignored = ignored

    @pretty = ""
    @queries = []

    @metrics = {
      global_time: 0, 
      global_sql_time: 0, 
      global_sql_call: 0, 
      files: {} 
    }
  end

  def self.watch(file_pattern = nil, &block)
    Hinter.new(file_pattern: file_pattern).watch(&block)
  end

  def watch(&block)
    ActiveSupport::Notifications.subscribed(active_record_callback, "sql.active_record") do
      started_at = Time.current
      block.call
      @metrics[:global_time] = (Time.current - started_at)
    end

    enrich_data!
    refresh_pretty!

    self
  end

  def top_query
    top_queries(1)
  end

  def top_queries(limit = 1)
    @queries.first(limit)
  end

  private

  def active_record_callback
    lambda { |name, started, finished, unique_id, data|
      time = (finished - started)
      
      caller.select do |row| 
        row =~ /#{@watch_dir}/ && 
        !(row =~ /#{@ignored}/) && 
        (!@file_pattern || row =~ /#{@file_pattern}/) 
      end.first(1).each do |row|
        line_number = extract_line_number(row)
        file_name = extract_file_name(row).to_sym

        @metrics[:files][file_name] ||= {}
        @metrics[:files][file_name][line_number] ||= { total_time: 0, nb_call: 0, queries: [] }
        @metrics[:files][file_name][line_number][:total_time] += time
        @metrics[:files][file_name][line_number][:nb_call] += 1
       
        query = {
          file_name: file_name,
          line: line_number,
          time: time,      
          sql: data[:sql],
        }

        @queries << query
        @metrics[:files][file_name][line_number][:queries] << query
      end

      @metrics[:global_sql_time] += time
      @metrics[:global_sql_call] += 1
    }
  end

  def enrich_data!
    @queries = @queries.sort_by{|query| query[:time] }.reverse

    @metrics[:files].keys.each do |file|
      @metrics[:files][file] = @metrics[:files][file].sort_by{|line, data| data[:total_time] }.reverse.to_h

      file_content = File.read(file.to_s) rescue nil

      @metrics[:files][file].each do |line, data|
        data[:file] = file
        data[:queries] = data[:queries].sort_by{|query| query[:time] }.reverse
        data[:rate_time] = (data[:total_time] * 100 / @metrics[:global_sql_time]).to_f.round(2)
        data[:total_time] =  data[:total_time].to_f.round(@round_time)
        data[:code] = (file_content ? file_content.lines[line - 1].strip : '-')
      end
    end

    @metrics[:files] = @metrics[:files].sort_by do |file, lines|
      lines.values.map{ |value| value[:total_time] } || 0
    end.reverse.to_h
  end

  def refresh_pretty!
    active_record_rate = (@metrics[:global_sql_time] * 100 / @metrics[:global_time]).round(@round_time)
    global = "global: #{@metrics[:global_time].round(@round_time)}s"
    sql = "sql: #{active_record_rate}% (totat: #{@metrics[:global_sql_time].round(@round_time)}s, #{pretty_call(@metrics[:global_sql_call])})"
    ruby = "ruby: #{(100 - active_record_rate).round(@round_time)}% (total: #{(@metrics[:global_time] - @metrics[:global_sql_time]).round(@round_time)}s)"
    #{self}
    @pretty = "#{global.green} \e[35m#{sql}\e[0m #{ruby.blue}\n"

    @metrics[:files].keys.each do |file|
      @pretty << "#{file.to_s.cyan}\n"

      @metrics[:files][file].each do |line, data|
        @pretty << "##{line}\t#{pretty_rate(data)}\t\e[3m#{data[:code].gray}\e[23m\n"
      end

      @pretty << "\n"
    end
  end

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

  def extract_line_number(row)
    row.scan(/:(\d+):/).flatten.last.to_i
  end

  def extract_file_name(row)
    row.split(":").first
  end

  def inspect
    return @pretty
  end
end