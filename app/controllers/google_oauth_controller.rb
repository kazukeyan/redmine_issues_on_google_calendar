class GoogleOauthController < ActionController::Base

  def callback
    $google_api_client.authorization.code = params[:code]
    $google_api_client.authorization.fetch_access_token!
    redirect_to root_path
  end

end
