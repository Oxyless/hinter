module Helpers
  module Json
    def to_h(details: true)
      hash = {
        sql_call: @metrics.sql_call,
        sql_time: @metrics.sql_time_rounded,
        ruby_time: @metrics.ruby_time_rounded,
        global_time: @metrics.global_time_rounded
      }

      if details
        hash[:files] = {}

        @metrics.files.keys.each do |file|
          hash[:files][file.to_s] = hash_file = []
    
          @metrics.files[file].each do |line, data|
            hash_file << {
              nb_call: data[:nb_call],
              total_time: data[:total_time], 
              line: line,
              code: data[:code]
            }
          end
        end
      end

      hash
    end

    def to_json
      to_h.to_json
    end
  end
end