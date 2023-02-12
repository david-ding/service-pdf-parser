class StringUtils
  SUPPORTED_REGEX_MODIFIERS = {
    m: Regexp::MULTILINE,
    x: Regexp::EXTENDED
  }.freeze

  def self.regexp_pattern?(string)
    string =~ %r{^/.*/[mx]*$}m
  end

  def self.to_regexp(string)
    raise "#{string} is not a regexp pattern" unless StringUtils.regexp_pattern?(string)

    %r{^/(?<pattern>.*)/(?<modifiers>[mx]*)$}m =~ string

    unless modifiers&.empty?
      return Regexp.new(
        pattern,
        modifiers.split('').map { |m| SUPPORTED_REGEX_MODIFIERS[m.to_sym] }.reduce(:|)
      )
    end
    Regexp.new(pattern)
  end
end
