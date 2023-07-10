# frozen_string_literal: true

require 'json'
require 'base64'
require 'pdf-reader'
require 'time'
require 'lib/string_utils'

def lambda_handler(event:, context:)
  file = Base64.decode64(event["file"])
  regex = StringUtils.to_regexp(event["regex"])

  reader = PDF::Reader.new(StringIO.new(file))
  text_content = reader.pages.map(&:text).join("\n")

  { statusCode: 200, body: JSON.generate(parse_text(text_content, regex)) }
rescue AttachmentParserException => e
  { statusCode: 422, body: JSON.generate(error: e.message) }
rescue Exception => e
  { statusCode: 500, body: JSON.generate(error: e.message) }
end

private

def parse_text(text_content, regex)
  unless (matches = text_content.match(regex))
    raise AttachmentParserException, "Unable to parse attachment. Text content:\n#{text_content}\nRegex:\n#{regex}"
  end

  matches.named_captures.inject({}) do |normalized_hash, (key, value)|
    normalized_hash[key] = normalize_match(key, value)
    normalized_hash
  end
end

def normalize_match(key, value)
  if key.end_with?('_date')
    return Time.parse(value).iso8601
  end

  value
end

class AttachmentParserException < RuntimeError
end
