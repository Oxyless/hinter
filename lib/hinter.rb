require_relative "./helpers/print"
require_relative "./helpers/utils"
require_relative "./helpers/color"
require_relative "./helpers/json"

require_relative "./hinters/metrics"
require_relative "./hinters/list"
require_relative "./hinters/ruby"

class Hinter  
  attr_reader :metrics, :callstacks

  include Helpers::Print
  include Helpers::Utils
  include Helpers::Color
  include Helpers::Json
  
  def initialize(
    file_pattern: nil,
    warning_time: 1,
    critical_time: 5,
    warning_sql_call: 10,
    critical_sql_call: 100,
    round_time: 2,
    colors: true,
    watch_dir: /\/app\//,
    ignored: /(\/gems\/|\(pry\)|bin\/rails|hinter)/,
    debug: false
  )
    @old_logger = ActiveRecord::Base.logger

    @options = {
      file_pattern: file_pattern,
      warning_time: warning_time,
      critical_time: critical_time,
      warning_sql_call: warning_sql_call,
      critical_sql_call: critical_sql_call,
      round_time: round_time,
      colors: (colors == true),
      watch_dir: watch_dir,
      ignored: ignored,
      debug: debug
    }

    @started_at = nil
    @subscriber =nil
    @pretty = ""

    @callstacks = {}
    @metrics = Hinters::Metrics.new(round_time: round_time)  
  end

  def self.watch(**options)
    if block_given?
      Hinter.new(**options).watch { yield }
    else
      Hinter.new(**options).watch
    end
  end

  def watch(context = nil, source: nil)
    ActiveRecord::Base.logger = nil
    @started_at = Time.current

    if context
      if block_given?
        Hinters::Ruby.new(context, @options, source: source).watch { yield } 
      else
        Hinters::Ruby.new(context, @options, source: source).watch
      end
    else
      if block_given?
        watch_block { yield }
      else
        @subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") { |*args| active_record_callback.call(*args) }
      end

      self
    end 
  end

  def stop
    if @started_at
      ActiveRecord::Base.logger = @old_logger

      if @subscriber
        ActiveSupport::Notifications.unsubscribe(@subscriber)
        @subscriber = nil
      end
    
      @metrics.global_time = (Time.current - @started_at)
      @metrics.enrich_data!

      @started_at = nil
    end

    self
  end

  def expand(caller_id)
    @callstacks[caller_id]
  end

  private

  def watch_block(&block)
    ActiveSupport::Notifications.subscribed(active_record_callback, "sql.active_record") do
      yield
      @metrics.global_time = (Time.current - @started_at)
    end

    @metrics.enrich_data!
  end

  def active_record_callback
    lambda { |name, started, finished, unique_id, data|
      time = (finished - started)
      callstack = caller.select do |row| 
        row =~ /#{@options[:watch_dir]}/ && 
        !(row =~ /#{@options[:ignored]}/) && 
        (!@options[:file_pattern] || row =~ /#{@options[:file_pattern]}/) 
      end

      last_on_stack = callstack.first(1)[0]
      last_on_stack = caller.first if !last_on_stack

      analyse_row!(data, time, last_on_stack, callstack.presence || caller)

      @metrics.global_sql_time += time
      @metrics.global_sql_call += 1
    }
  end

  def analyse_row!(data, time, row, callstack)
    line_number = extract_line_number(row)
    file_name = extract_file_name(row).to_sym
    file_content = @metrics.cached_file_content(file_name)

    @callstacks["#{file_name}##{line_number}"] ||= callstack
    @callstacks[line_number] ||= callstack
    
    @metrics.files[file_name] ||= {}
    @metrics.files[file_name][line_number] ||= { total_time: 0, nb_call: 0, queries: [] }
    @metrics.files[file_name][line_number][:total_time] += time
    @metrics.files[file_name][line_number][:nb_call] += 1
   
    query = {
      file_name: file_name,
      line: line_number,
      time: time,      
      sql: data[:sql],
      code: (file_content ? file_content.lines[line_number - 1].strip : '-')
    }

    @metrics.queries << query
    @metrics.files[file_name][line_number][:queries] << query
  end
end