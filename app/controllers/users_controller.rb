# frozen_string_literal: true

class UsersController < ApplicationController
  def new
    @user = OauthService.call(params[:code])
    redirect_to root_path, alert: :Unauthorized unless @user
  end
end
