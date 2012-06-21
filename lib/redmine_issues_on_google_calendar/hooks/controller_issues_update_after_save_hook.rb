module RedmineIssuesOnGoogleCalendar
  module Hooks
    class ControllerIssuesUpdateAfterSaveHook < Redmine::Hook::ViewListener
      def controller_issues_update_after_save(context={})
        context[:issue].update_google_calendar_event
      end
    end
  end
end