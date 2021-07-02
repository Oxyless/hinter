module Hinters
  module Ruby
    def self.included(klass)
      klass.extend(ClassMethods)
    end
  
    module ClassMethods
      def ruby(context, source: nil, separator: /\;$/, &block)
        source = instrument_source(source.split("\n") || block.source.split("\n")[1..-2], separator: separator)
        context.eval(source)
      end
    
      def instrument_source(source, separator: nil)
        source.each_with_index do |row, idx|
          if !separator || row.strip =~ separator
            source[idx] = <<~RUBY
              __start_at = Time.current;
              #{row}
              __perf[#{idx}] = {
                time: (Time.current - __start_at).second.round(3),
                code: '#{row.strip.tr("'", '"')}'
              };
            RUBY
          end
        end
    
        <<~RUBY
          __perf = {};
          #{source.join("\n")};
          __perf;
        RUBY
      end
    end
  end
end