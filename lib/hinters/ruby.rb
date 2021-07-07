require 'ripper'
module Hinters
  class Ruby
    def initialize(context, options, source: nil)
      @context = context
      @options = options
      @source = source
    end

    def watch(&block)
      source = instrument_source(@source || block.source.split("\n")[1..-2].join("\n"))
      @context.eval(source)
    end

    private

    def instrument_source(source)
      instrumented_source = []

      to_instructions(source).each_with_index do |instruction|
        instrumented_source << <<~RUBY
          __hinter = Hinter.watch(#{to_params(@options)})
          #{instruction}
          __hinters.hinters['#{instruction.strip.tr("'", '"')}'] = __hinter.stop
        RUBY
      end

      <<~RUBY
        __hinters = Hinters::List.new(#{to_params(@options)});
        #{instrumented_source.join("\n")};
        __hinters;
      RUBY
    end

    def to_instructions(code)
      tokens = ::Ripper.tokenize(code)
      instructions = []
      instruction = ""
      opened = 0
      prev_token = ""

      tokens.each do |token|
        instruction += token

        case token
          when "if"
            opened += 1 if instruction.strip.size == 2
          when "(", "{", "[", "case", "while", "for", "do", "def", "class", "module"
            opened += 1
          when ")", "}", "]", "end"
            opened -= 1
          when "\n", ";"
            if prev_token != "," && opened == 0 && instruction.strip.size > 0
              instructions << instruction.strip
              instruction = ""
            end
        end

        prev_token = token
      end

      if instruction.strip.size > 0
        instructions << instruction
      end

      instructions
    end

    def to_params(options)
      options.map do |key, value|
        str_value = case value
        when nil
          "nil"
        when TrueClass, FalseClass
          "#{value}"
        when Numeric
          "#{value}"
        when String
          "\"#{value}\""
        when Symbol
          ":#{value}"
        when Regexp
          "/#{value.source.gsub("/", "\\/")}/"
        when Hash
          value.to_json
        end

        "#{key}: #{str_value}"
      end.join(", ")
    end
  end
end