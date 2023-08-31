class StringUtils
  SUPPORTED_REGEX_MODIFIERS = {
    m: Regexp::MULTILINE,
    x: Regexp::EXTENDED
  }.freeze

  def self.regexp_pattern?(string)
    string =~ %r{^/.*/[mx]*$}m || string =~ /^\(\?.*\)$/m
  end

  def self.to_regexp(string)
    raise "#{string} is not a regexp pattern" unless regexp_pattern?(string)

    %r{^/(?<pattern>.*)/(?<modifiers>[mx]*)$}m =~ string

    unless modifiers.nil?
      return Regexp.new(
        pattern,
        modifiers.split("").map { |m| SUPPORTED_REGEX_MODIFIERS[m.to_sym] }.reduce(:|)
      )
    end

    return Regexp.new(pattern) unless pattern.nil?

    Regexp.new(string)
  end
end
