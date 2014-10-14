require 'parslet'
require 'color'

class ColorParser < Parslet::Parser

  root :color
  rule(:color) { rgb_hex | rgb_fun | hsl_fun }

  rule(:hex_digit) { match('[0-9a-fA-F]') }
  rule(:rgb_hex) { str('#') >> (rgb_hex_long | rgb_hex_short) }
  rule(:rgb_hex_short) { hex_digit.as(:hex_digit).as(:red) >> hex_digit.as(:hex_digit).as(:green) >> hex_digit.as(:hex_digit).as(:blue) }
  rule(:rgb_hex_long) { hex_digit.repeat(2,2).as(:hex_pair).as(:red) >> hex_digit.repeat(2,2).as(:hex_pair).as(:green) >> hex_digit.repeat(2,2).as(:hex_pair).as(:blue) }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:comma) { space? >> str(',') >> space? }
  rule(:int) { match('[0-9]').repeat(1) }
  rule(:pct) { match('[0-9]').repeat(1) >> str('%') }

  rule(:rgb_fun) { rgb_fun_int | rgb_fun_pct }
  rule(:rgb_fun_int) { str('rgb(') >> space? >> pct.as(:rgb_pct).as(:red) >> comma >> pct.as(:rgb_pct).as(:green) >> comma >> pct.as(:rgb_pct).as(:blue) >> space? >> str(')') }
  rule(:rgb_fun_pct) { str('rgb(') >> space? >> int.as(:rgb_int).as(:red) >> comma >> int.as(:rgb_int).as(:green) >> comma >> int.as(:rgb_int).as(:blue) >> space? >> str(')') }

  rule(:hsl_fun) { str('hsl(') >> space? >> int.as(:hue) >> comma >> pct.as(:sat) >> comma >> pct.as(:lum) >> space? >> str(')') }
end

class ColorTransformer < Parslet::Transform
  rule(:rgb_int => simple(:rgb_int)) { rgb_int.to_i }
  rule(:rgb_pct => simple(:rgb_pct)) { (rgb_pct.to_i / 100.0 * 255).floor }

  rule(hex_digit: simple(:hex_digit)) { (hex_digit.to_s * 2).hex }
  rule(hex_pair: simple(:hex_pair)) { hex_pair.to_s.hex }

  rule(red: simple(:red), green: simple(:green), blue: simple(:blue)) { Color::RGB.new(red, green, blue) }

  rule(hue: simple(:hue), sat: simple(:sat), lum: simple(:lum)) { Color::HSL.new(hue.to_i, sat.to_i, lum.to_i) }
end
