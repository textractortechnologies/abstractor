module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSchema
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_object_type
          base.send :has_many, :abstractor_subjects
          base.send :has_many, :abstractor_abstraction_schema_predicate_variants
          base.send :has_many, :abstractor_abstraction_schema_object_values
          base.send :has_many, :abstractor_object_values, :through => :abstractor_abstraction_schema_object_values
          base.send :has_many, :object_relations,   :class_name => "Abstractor::AbstractorAbstractionSchemaRelation", :foreign_key => "object_id"
          base.send :has_many, :subject_relations,  :class_name => "Abstractor::AbstractorAbstractionSchemaRelation", :foreign_key => "subject_id"

          # base.send :attr_accessible, :abstractor_object_type, :abstractor_object_type_id, :display_name, :predicate, :preferred_name, :deleted_at
        end

        # Instance Methods
        ##
        # All of the different ways of referring to the predicate.
        #
        # @return [Array<String>]
        def predicate_variants
          [preferred_name].concat(abstractor_abstraction_schema_predicate_variants.map(&:value))
        end

        ##
        # Whether or not it is a list.
        #
        # @return [Boolean]
        def object_type_list?
          case abstractor_object_type.value
          when Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST, Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_RADIO_BUTTON_LIST
            true
          else
            false
          end
        end
      end
    end
  end
end
