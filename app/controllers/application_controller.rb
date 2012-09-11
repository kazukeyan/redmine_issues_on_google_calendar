class ApplicationController < ActionController::Base

  before_filter :authorize_google_oauth

  # TODO: グローバル変数は出来るだけ使わないようにする
  $google_api_client

  def ApplicationController.get_google_oauth_settings
    require 'google/api_client'
    oauth_yaml = YAML.load_file("#{Pathname.new(__FILE__).parent.parent.parent}/config/google-api.yaml")
    google_api_client = Google::APIClient.new
    google_api_client.authorization.client_id = oauth_yaml["client_id"]
    google_api_client.authorization.client_secret = oauth_yaml["client_secret"]
    google_api_client.authorization.scope = oauth_yaml["scope"]
    google_api_client.authorization.redirect_uri = oauth_yaml["redirect_uri"]
    $google_api_client = google_api_client
  end
  
  def authorize_google_oauth
    if $google_api_client.authorization.refresh_token && $google_api_client.authorization.expired?
      $google_api_client.authorization.fetch_access_token!
    end
    unless $google_api_client.authorization.access_token
      redirect_to $google_api_client.authorization.authorization_uri.to_s
    end
    return nil
  end
  
  unless defined?($google_api_client)
    $google_api_client = get_google_oauth_settings
  end
end
