ActionController::Routing::Routes.draw do |map|
  map.connect 'google_oauth/callback', :controller => 'google_oauth', :action => 'callback'
  map.resources :projects do |projects|
    projects.edit_google_calendar '/google_calendar', :controller => 'project_calendars', :action => 'edit', :conditions => { :method => :get }
    projects.update_google_calendar '/google_calendar/update', :controller => 'project_calendars', :action => 'update', :conditions => { :method => :put }
  end
  
end