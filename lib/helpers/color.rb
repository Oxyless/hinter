module Helpers
  module Color
    def color(str, code)
      if @options[:colors]
        "\e[#{code}m#{str}\e[0m"
      else
        str
      end
    end

    def black(str)    color(str, 30) end
    def red(str)      color(str, 31) end
    def green(str)    color(str, 32) end
    def yellow(str)    color(str, 33) end
    def blue(str)     color(str, 34) end
    def magenta(str)  color(str, 35) end
    def cyan(str)     color(str, 36) end
    def gray(str)     color(str, 37) end
    
    def bg_black(str)  color(str, 40) end
    def bg_red(str)    color(str, 41) end
    def bg_green(str)  color(str, 42) end
    def bg_yellow(str)  color(str, 43) end
    def bg_blue(str)   color(str, 44) end
    def bg_magenta(str) color(str, 45) end
    def bg_cyan(str)    color(str, 46) end
    def bg_gray(str)    color(str, 47) end
    
    def bold(str)       color(str, 1) end
    def italic(str)     color(str, 3) end
    def underline(str)  color(str, 4) end
    def blink(str)      color(str, 5) end
    def reverse_color(str)  color(str, 7) end

    def bold_black(str)    bold(color(str, 30)) end
    def bold_red(str)      bold(color(str, 31)) end
    def bold_green(str)    bold(color(str, 32)) end
    def bold_yellow(str)    bold(color(str, 33)) end
    def bold_blue(str)     bold(color(str, 34)) end
    def bold_magenta(str)  bold(color(str, 35)) end
    def bold_cyan(str)     bold(color(str, 36)) end
    def bold_gray(str)     bold(color(str, 37)) end

    def italic_black(str)    italic(color(str, 30)) end
    def italic_red(str)      italic(color(str, 31)) end
    def italic_green(str)    italic(color(str, 32)) end
    def italic_yellow(str)    italic(color(str, 33)) end
    def italic_blue(str)     italic(color(str, 34)) end
    def italic_magenta(str)  italic(color(str, 35)) end
    def italic_cyan(str)     italic(color(str, 36)) end
    def italic_gray(str)     italic(color(str, 37)) end
  end
end