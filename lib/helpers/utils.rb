module Helpers
  module Utils  
    def extract_line_number(row)
      row.scan(/:(\d+):/).flatten.last.to_i
    end
  
    def extract_file_name(row)
      row.split(":").first
    end
  end
end