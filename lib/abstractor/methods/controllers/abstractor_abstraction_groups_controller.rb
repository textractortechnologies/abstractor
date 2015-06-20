module Abstractor
  module Methods
    module Controllers
      module AbstractorAbstractionGroupsController
        def self.included(base)
          base.send :helper, :all
          base.send :before_filter, :set_abstractor_abstraction_group, only: [:destroy, :update, :update_wokflow_status]
        end

        def create
          @abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: params[:abstractor_subject_group_id], about_type: params[:about_type], about_id: params[:about_id])

          abstractor_subjects = @abstractor_abstraction_group.abstractor_subject_group.abstractor_subjects
          unless params[:namespace_type].blank? || params[:namespace_id].blank?
            @namespace_id   = params[:namespace_id]
            @namespace_type = params[:namespace_type]
            abstractor_subjects = abstractor_subjects.where(namespace_type: @namespace_type, namespace_id: @namespace_id)
          end

          abstractor_subjects.each do |abstractor_subject|
            abstraction = abstractor_subject.abstractor_abstractions.build(about_id: params[:about_id], about_type: params[:about_type], workflow_status: Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_PENDING)
            abstractor_subject.abstractor_abstractions.where(about_id: params[:about_id], about_type: params[:about_type]).each do |abstractor_abstraction|
              if !abstractor_abstraction.abstractor_abstraction_group.removable?
                abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
                  suggestion_sources = []
                  abstractor_suggestion.abstractor_suggestion_sources.each do |abstractor_suggestion_source|
                    suggestion_sources << Abstractor::AbstractorSuggestionSource.new(match_value: abstractor_suggestion_source.match_value, sentence_match_value: abstractor_suggestion_source.sentence_match_value, source_id: abstractor_suggestion_source.source_id, source_method: abstractor_suggestion_source.source_method, source_type: abstractor_suggestion_source.source_type, custom_method: abstractor_suggestion_source.custom_method, custom_explanation: abstractor_suggestion_source.custom_explanation, section_name: abstractor_suggestion_source.section_name)
                  end

                  abstraction.abstractor_suggestions.build(suggested_value: abstractor_suggestion.suggested_value, unknown: abstractor_suggestion.unknown, not_applicable: abstractor_suggestion.not_applicable, accepted: nil, abstractor_object_value: abstractor_suggestion.abstractor_object_value, abstractor_suggestion_sources: suggestion_sources)
                end
              end
            end

            abstraction.abstractor_subject.abstractor_abstraction_sources.select { |s| s.abstractor_abstraction_source_type.name == 'indirect' }.each do |abstractor_abstraction_source|
              source = abstractor_subject.subject_type.constantize.find(params[:about_id]).send(abstractor_abstraction_source.from_method)
              abstraction.abstractor_indirect_sources.build(abstractor_abstraction_source: abstractor_abstraction_source, source_type: source[:source_type], source_method: source[:source_method])
            end
            @abstractor_abstraction_group.abstractor_abstractions << abstraction
          end
          @abstractor_abstraction_group.save!

          respond_to do |format|
            format.html { render action: "edit", layout: false }
          end
        end

        def destroy
          if @abstractor_abstraction_group.soft_delete!
            flash[:notice] = "Group was successfully deleted."
          else
            flash[:error] = "Group could not be deactivated: #{abstractor_abstraction_group.errors.full_messages.join(',')}"
          end
          respond_to do |format|
            format.js   { head :no_content }
            format.json { head :no_content }
          end
        end

        def update
          abstractor_abstraction_value = params[:abstractor_abstraction_value]
          Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@abstractor_abstraction_group.abstractor_abstractions, abstractor_abstraction_value)
          respond_to do |format|
            format.html { render action: "edit", layout: false }
          end
        end

        def update_wokflow_status
          abstraction_workflow_status = params[:abstraction_workflow_status]
          Abstractor::AbstractorAbstraction.update_abstractor_abstraction_workflow_status(@abstractor_abstraction_group.abstractor_abstractions, abstraction_workflow_status)
          respond_to do |format|
            format.html { render action: "edit", layout: false }
          end
        end

        private
          def set_abstractor_abstraction_group
            @abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.find(params[:id])
          end
      end
    end
  end
end