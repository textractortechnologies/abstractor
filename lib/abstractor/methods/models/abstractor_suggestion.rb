module Abstractor
  module Methods
    module Models
      module AbstractorSuggestion
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction

          base.send :has_one, :abstractor_suggestion_object_value, dependent: :destroy
          base.send :has_one, :abstractor_object_value, through: :abstractor_suggestion_object_value

          base.send :has_many, :abstractor_suggestion_sources, dependent: :destroy

          # Hooks
          base.send :after_save, :update_abstraction_value, :if => lambda {|abstractor_suggestion| abstractor_suggestion.accepted_changed? }
          base.send :after_save, :update_siblings_status, :if => lambda {|abstractor_suggestion| abstractor_suggestion.accepted_changed? }
          base.send :after_create, :update_siblings_status, :if => lambda {|abstractor_suggestion| abstractor_suggestion.accepted.nil? }
        end

        # Instance Methods
        def update_abstraction_value
          if accepted
            abstractor_abstraction.value                     = suggested_value
            abstractor_abstraction.unknown                   = unknown
            abstractor_abstraction.not_applicable            = not_applicable
            abstractor_abstraction.save!
          elsif accepted.nil?
            abstractor_abstraction.value          = nil
            abstractor_abstraction.unknown        = nil
            abstractor_abstraction.not_applicable = nil
            abstractor_abstraction.save!
          elsif accepted == false
            abstractor_abstraction.value          = nil if abstractor_abstraction.value == suggested_value
            abstractor_abstraction.unknown        = nil if unknown && abstractor_abstraction.unknown == unknown
            abstractor_abstraction.not_applicable = nil if not_applicable && abstractor_abstraction.not_applicable == not_applicable
            abstractor_abstraction.save!
          end
        end

        def update_siblings_status
          if accepted
            #reject sibling suggestions
            self.sibling_suggestions.each do |abstractor_suggestion|
              abstractor_suggestion.accepted = false
              abstractor_suggestion.save!
            end
          elsif accepted.nil?
            #reset status on sibling suggestions
            self.sibling_suggestions.each do |abstractor_suggestion|
              abstractor_suggestion.accepted = nil
              abstractor_suggestion.save!
            end
          end
        end

        def display_value
          if unknown
            'unknown'
          elsif not_applicable
            'not applicable'
          else
            suggested_value
          end
        end

        def sibling_suggestions
          abstractor_abstraction.abstractor_suggestions.where('id != ?', id)
        end

        def detect_abstractor_suggestion_source(abstractor_abstraction_source, sentence_match_value, source_id, source_type, source_method, section_name)
          abstractor_suggestion_source = abstractor_suggestion_sources.detect do |abstractor_suggestion_source|
            abstractor_suggestion_source.abstractor_abstraction_source == abstractor_abstraction_source &&
            abstractor_suggestion_source.sentence_match_value == sentence_match_value &&
            abstractor_suggestion_source.source_id == source_id &&
            abstractor_suggestion_source.source_type == source_type &&
            abstractor_suggestion_source.source_method == source_method &&
            abstractor_suggestion_source.section_name == section_name
          end
        end
      end
    end
  end
end