# frozen_string_literal: true

require 'json'
require 'base64'
require 'pdf-reader'
require 'time'
require 'lib/string_utils'

def lambda_handler(event:, context:)
  params = params(event)
  reader = PDF::Reader.new(StringIO.new(params[:file]))
  text_content = reader.pages.map(&:text).join("\n")

  { statusCode: 200, body: parse_text(text_content, params[:regex]) }
rescue AttachmentParserException => e
  { statusCode: 422, body: { error: e.message } }
rescue Exception => e
  { statusCode: 500, body: { error: e.message } }
end

private

def params(event)
  # event["body"] is only present when invoked via API Gateway
  payload = event["body"].nil? ? event : JSON.parse(event["body"])

  {
    file: Base64.decode64(payload["file"]),
    regex: StringUtils.to_regexp(payload["regex"])
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
