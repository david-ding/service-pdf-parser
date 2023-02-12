# frozen_string_literal: true

require 'json'
require 'base64'
require 'pdf-reader'
require 'time'
require 'lib/string_utils'

def lambda_handler(event:, context:)
  params = params(event["body"])

  reader = PDF::Reader.new(StringIO.new(params[:file]))
  text_content = reader.pages.first.text

  { statusCode: 200, body: JSON.generate(parse_text(text_content, params[:regex])) }
rescue AttachmentParserException => e
  { statusCode: 422, body: JSON.generate(error: e.message) }
end

private

def params(body_json)
  body = JSON.parse(body_json)

  {
    file: Base64.decode64(body["file"]),
    regex: StringUtils.to_regexp(body["regex"])
  }
end

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
