module Abstractor
  module Methods
    module Models
      module AbstractorAbstraction
        def self.included(base)
          base.send :include, SoftDelete
          base.send :has_paper_trail

          # Associations
          base.send :belongs_to, :abstractor_subject

          base.send :has_many, :abstractor_suggestions
          base.send :has_many, :abstractor_abstraction_sources, :through => :abstractor_abstractor_suggestions
          base.send :has_many, :abstractor_indirect_sources

          base.send :has_one, :abstractor_abstraction_group_member
          base.send :has_one, :abstractor_abstraction_group, :through => :abstractor_abstraction_group_member
          base.send :has_one, :abstractor_abstraction_schema, :through => :abstractor_subject

          base.send :accepts_nested_attributes_for, :abstractor_suggestions
          base.send :accepts_nested_attributes_for, :abstractor_indirect_sources

          base.send :belongs_to, :about, polymorphic: true

          base.send :validates_associated, :abstractor_subject

          # Hooks
          base.send :after_save, :review_suggestions

          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)
        end

        module InstanceMethods
          def discarded?
            workflow_status == Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED
          end

          def submitted?
            workflow_status == Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
          end

          def clear
            self.value = nil
            self.unknown = nil
            self.not_applicable = nil
          end

          def clear!
            Abstractor::AbstractorAbstraction.transaction do
              self.clear
              self.save!
              self.abstractor_suggestions.each do |abstractor_suggestion|
                if abstractor_suggestion.abstractor_suggestion_sources.not_deleted.empty?
                  abstractor_suggestion.destroy
                else
                  abstractor_suggestion.accepted = nil
                  abstractor_suggestion.save!
                end
              end
            end
          end

          def review_suggestions
            matching_abstractor_suggestions.each do |abstractor_suggestion|
              abstractor_suggestion.accepted = true
              abstractor_suggestion.save!
            end

            abstractor_suggestions.each do |abstractor_suggestion|
              if value && abstractor_suggestion.suggested_value && value != abstractor_suggestion.suggested_value
                abstractor_suggestion.accepted = false
                abstractor_suggestion.save!
              end

              if unknown && unknown != abstractor_suggestion.unknown
                abstractor_suggestion.accepted = false
                abstractor_suggestion.save!
              end

              if not_applicable && not_applicable != abstractor_suggestion.not_applicable
                abstractor_suggestion.accepted = false
                abstractor_suggestion.save!
              end
            end
          end

          def matching_abstractor_suggestions
            unknown_values        = unknown ? unknown : [unknown, nil]
            not_applicable_values = not_applicable ? not_applicable : [not_applicable, nil]
            suggested_values = value.blank? ? ['', nil] : value
            abstractor_suggestions.where(unknown: unknown_values, not_applicable: not_applicable_values, suggested_value: suggested_values)
          end

          def display_value
            if unknown
              'unknown'
            elsif not_applicable
              'not applicable'
            elsif value.blank?
              '[Not set]'
            else
              value
            end
          end

          def detect_abstractor_suggestion(suggested_value, unknown, not_applicable)
            abstractor_suggestion = nil
            abstractor_suggestion = abstractor_suggestions(true).detect do |abstractor_suggestion|
              abstractor_suggestion.suggested_value == suggested_value &&
              abstractor_suggestion.unknown == unknown &&
              abstractor_suggestion.not_applicable == not_applicable
            end
          end

          ##
          # Determines if the abstraction has been reviewed.
          #
          # @return [Boolean]
          def unreviewed?
            (value.blank? && unknown.blank? && not_applicable.blank?)
          end

          ##
          # Detects if the abstraction already has an Abstractor::AbstractorIndirectSource based on the Abstractor::AbstractorAbstractionSource passed via the abstractor_abstraction_source parameter.
          # Retuns it if present.  Otherwise nil.
          #
          # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source An instance of Abstractor::AbstractorAbstractionSource to check for the presence of an Abstractor::AbstractorIndirectSource.
          # @return [Abstractor::AbstractorIndirectSource, nil]
          def detect_abstractor_indirect_source(abstractor_abstraction_source)
            abstractor_indirect_source = nil
            abstractor_indirect_source = abstractor_indirect_sources(true).detect do |ais|
              ais.abstractor_abstraction_source == abstractor_abstraction_source
            end
          end

          ##
          # Returns all the suggestions for the abstraction with a suggestion status of 'needs review'
          #
          # @return [ActiveRecord::Relation] List of [Abstractor::AbstractorSuggestion].
          def unreviewed_abstractor_suggestions
            abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.accepted.nil? }
          end

          ##
          # Remove suggestions on the abstraction with a suggestion status of 'needs review' that are not present in the array of hashes representing suggestions passed in.
          #
          # @param [Array<Hash>] suggestions
          # @return [void]
          def remove_unreviewed_suggestions_not_matching_suggestions(suggestions)
            unreviewed_abstractor_suggestions.each do |abstractor_suggestion|
              not_detritus = suggestions.detect { |suggestion| suggestion[:suggestion] == abstractor_suggestion.suggested_value }
              unless not_detritus
                abstractor_suggestion.destroy
              end
            end
          end
        end

        module ClassMethods
          ##
          # Updates all abstractor abstractions passed in to a workflow status of 'pending' or 'submitted'.
          #
          # @param [Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_PENDING, Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED] abstraction_workflow_status controls whether to update all abstractor abstractions in the group to 'pending' or 'submitted'
          # @return [void]
          def update_abstractor_abstraction_workflow_status(abstractor_abstractions, abstraction_workflow_status)
            raise(ArgumentError, "abstraction_workflow_status argument invalid") unless Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUSES.include?(abstraction_workflow_status)
            Abstractor::AbstractorAbstraction.transaction do
              if abstraction_workflow_status
                abstractor_abstractions.each do |abstractor_abstraction|
                  abstractor_abstraction.workflow_status = abstraction_workflow_status
                  abstractor_abstraction.save!
                end
              end
            end
          end

          ##
          # Updates all abstractor abstractions passed in to 'not applicable' or 'unknown'.
          #
          # @param [Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE] abstraction_other_value_type controls whether to update all abstractor abstractions in the group to 'unknown' or 'not applicable'
          # @return [void]
          def update_abstractor_abstraction_other_value(abstractor_abstractions, abstraction_other_value_type)
            raise(ArgumentError, "abstraction_value_type argument invalid") unless Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPES.include?(abstraction_other_value_type)

            case abstraction_other_value_type
            when Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN
              unknown = true
              not_applicable = false
            when Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE
              unknown = false
              not_applicable = true
            end

            Abstractor::AbstractorAbstraction.transaction do
              if abstraction_other_value_type
                abstractor_abstractions.each do |abstractor_abstraction|
                  abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
                    if unknown && abstractor_suggestion.unknown
                      abstractor_suggestion.accepted = true
                      abstractor_suggestion.save!
                    else
                      set_abstractor_abstraction(abstractor_abstraction, unknown, not_applicable)
                      abstractor_suggestion.accepted = false
                      abstractor_suggestion.save!
                    end
                  end

                  if abstractor_abstraction.abstractor_suggestions.empty?
                    abstractor_abstraction.unknown = unknown
                    abstractor_abstraction.not_applicable = not_applicable
                    abstractor_abstraction.save!
                  end
                end
              end
            end
          end

          private
            def set_abstractor_abstraction(abstractor_abstraction, unknown, not_applicable)
              abstractor_abstraction.value = nil
              abstractor_abstraction.unknown = unknown
              abstractor_abstraction.not_applicable = not_applicable
              abstractor_abstraction.save!
            end
        end
      end
    end
  end
end