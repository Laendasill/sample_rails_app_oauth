# frozen_string_literal: true

require 'pry-remote'

def kill_chain(result)
  result
end

def should_kill?(result)
  result.success? == false
end

class Result
  attr_accessor :value, :success
  def initialize(val, success = true)
    @value = val
    @success = success
  end

  def success?
    @success
  end

  def map
    if success?
      begin
      Result.new(yield(@value))
    rescue Exception => e
      Result.error(e)
    end
    else
      self
    end
  end

  def self.error(error)
    new(error.message, false)
  end
end
class OauthService
  def self.call(*args)
    new(args).call
  end
  @@CallOrder = %w[get_token parse_token get_user_info parse_user_info]
  def initialize(code)
    @logger = Logger.new(STDOUT)

    @params = {
      grant_type: :authorization_code,
      client_id: Rails.application.credentials[:UID],
      client_secret: Rails.application.credentials[:secret],
      redirect_uri: Rails.application.credentials[:callback_uri],
      code: code[0]
    }
  end

  def call
    result = @@CallOrder.inject(Result.new(@params)) do |sum, el|
      send(el, sum)
    end
    return result.value unless result.success? == false

    false
  end

  def get_token(result)
    @logger.debug('in get_token')
    result.map do |value|
      RestClient.post('https://shielded-temple-86762.herokuapp.com/oauth/token', value)
    end
  end

  def parse_token(result)
    result.map { |val| JSON.parse(val)['access_token'] }
  end

  def get_user_info(result)
    result.map do |value|
      RestClient.get('https://shielded-temple-86762.herokuapp.com/api/user/?token=' + value)
    end
  end

  def parse_user_info(result)
    result.map { |val| JSON.parse(val) }
  end
end
