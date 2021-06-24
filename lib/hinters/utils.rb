module Hinters
  module Utils
    def cached_file_content(file)
      @cached_file_content_ ||= {}
      @cached_file_content_[file] ||= File.read(file.to_s) rescue "-"
      @cached_file_content_[file]
    end
  
    def extract_line_number(row)
      row.scan(/:(\d+):/).flatten.last.to_i
    end
  
    def extract_file_name(row)
      row.split(":").first
    end
  end
end