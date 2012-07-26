module RedmineIssuesOnGoogleCalendar
  module Hooks
    class ViewIssuesIndexBottomHook < Redmine::Hook::ViewListener
      render_on(:view_issues_index_bottom, :partial => 'migrate_issues/migration_link', :layout => false)
    end
  end
end