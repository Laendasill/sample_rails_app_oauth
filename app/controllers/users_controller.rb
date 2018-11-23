class UsersController < ApplicationController
  def new
    code = params[:code]
    if code
      @user = OauthService.call(code_params)
      redirect_to root_path, alert: :Unauthorized unless @user[:success] == true
    end
  rescue RestClient::Unauthorized
    redirect_to root_path, alert: :Unauthorized
  end

private

  def code_params
    params.require(:code)
  end
end
