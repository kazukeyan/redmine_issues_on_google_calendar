module RedmineIssuesOnGoogleCalendar
  module Hooks
    class ControllerProjectsUpdateAfterSaveHook < Redmine::Hook::ViewListener
      def controller_projects_update_after_save(context={})
        context[:project].update_google_calendar
      end
    end
  end
end