module Abstractor
  module Methods
    module Models
      module AbstractorObjectValue
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_object_value_variants
          base.send :has_many, :abstractor_abstraction_schema_object_values
          base.send :has_many, :abstractor_abstraction_schemas, :through => :abstractor_abstraction_schema_object_values
          base.send :has_many, :abstractor_abstractions

          # Validations
          base.send :validates_presence_of, :value

          # Hooks
          base.send :before_save,   :soft_delete_abstractor_object_value_variants
          base.send :after_update,  :update_abstractor_abstraction_schema_object_values
          base.send :after_destroy, :update_abstractor_abstraction_schema_object_values    
          base.send :after_touch,   :update_abstractor_abstraction_schema_object_values

          base.send :accepts_nested_attributes_for, :abstractor_object_value_variants, allow_destroy: false
          
          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)
        end

        # Instance Methods
        module InstanceMethods
          def object_variants
            [value].concat(abstractor_object_value_variants.map(&:value))
          end

          def update_abstractor_abstraction_schema_object_values
            self.abstractor_abstraction_schema_object_values.reject(&:new_record?).map(&:touch)
          end

          def soft_delete_abstractor_object_value_variants
            self.abstractor_object_value_variants.select(&:marked_for_destruction?).map(&:process_soft_delete)
          end
        end

        # Class Methods
        module ClassMethods
          def search_across_fields(query)
            if query.blank?
              all
            else
              where("LOWER(value) LIKE ? OR LOWER(vocabulary) LIKE ? OR LOWER(vocabulary_version) LIKE ? OR LOWER(vocabulary_code) LIKE ?", *Array.new(4, "%#{query.downcase}%"))
            end
          end
        end
      end
    end
  end
end
