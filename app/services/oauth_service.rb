require 'pry-remote'

def kill_chain(result)
  result
end

def should_kill?(result)
  return result[:success] == false
end

class OauthService

  def self.call(*args)
    new(args).call
  end
  
  def initialize(code)
      @params = {
        grant_type: :authorization_code,
        client_id: Rails.application.credentials[:UID],
        client_secret: Rails.application.credentials[:secret],
        redirect_uri: Rails.application.credentials[:callback_uri],
        code: code
      }
  end

  def call
    result = ['get_token','parse_token','get_user_info','parse_user_info']
      .inject({success:true, value:@params}) { |sum,el|
        return send(el, sum)
      }
    result
  end

  def get_token(result)
    return kill_chain(result) if should_kill?(result)
    response = RestClient.post('https://shielded-temple-86762.herokuapp.com/oauth/token', result[:value])

    {success: true, value: response}
  rescue Exception => e

    {success: false, value: e.message}
  end

  def parse_token(result)

    return kill_chain(result) if should_kill?(result)
    access_token = JSON.parse(result[:value])['access_token']

    {success: true, result: access_token}
  rescue Exception => e
    {success: false, value: e.message}
  end

  def get_user_info(result)
    return kill_chain(result) if should_kill?(result)

    response = RestClient.get('https://shielded-temple-86762.herokuapp.com/api/user/?token=' + access_token)
    
    {success: true, value: response}
  rescue Exception => e
    {success: false, value: e.message}
  end

  def parse_user_info(result)
    return kill_chain(result) if should_kill?(result)
    
    user = JSON.parse(response)
    {success: true, value: user}
  rescue  Exception => e
    {success: false, value: e.message}
  end

end