module RedmineIssuesOnGoogleCalendar
  # Patches Redmine's IssuesController dynamically.
  module IssuesControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        alias_method_chain :update, :hook
      end

    end
    
    module ClassMethods
      # class_methods
    end
    
    module InstanceMethods
      # instance_methods
      def update_with_hook
        update_issue_from_params

        if @issue.save_issue_with_child_records(params, @time_entry)
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?
          call_hook(:controller_issues_update_after_save, { :params => params, :issue => @issue})
          respond_to do |format|
            format.html { redirect_back_or_default({:action => 'show', :id => @issue}) }
            format.api  { head :ok }
          end
        else
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?
          @journal = @issue.current_journal

          respond_to do |format|
            format.html { render :action => 'edit' }
            format.api  { render_validation_errors(@issue) }
          end
        end
      end
    end
  end
end