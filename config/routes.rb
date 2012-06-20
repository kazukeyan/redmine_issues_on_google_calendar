ActionController::Routing::Routes.draw do |map|
  map.connect 'google_oauth/callback', :controller => 'google_oauth', :action => 'callback'
end