module Abstractor
  module Methods
    module Models
      module AbstractorRule
        def self.included(base)
          base.send :include, SoftDelete
          base.send :has_paper_trail

          # Associations
          base.send :has_many, :abstractor_rule_abstractor_subjects, inverse_of: :abstractor_rule
          base.send :has_many, :abstractor_subjects,            through: :abstractor_rule_abstractor_subjects, inverse_of: :abstractor_rule
          base.send :has_many, :abstractor_abstraction_schemas, through: :abstractor_subjects

          base.send :accepts_nested_attributes_for, :abstractor_rule_abstractor_subjects, allow_destroy: false

          # Validations
          base.send :validates_presence_of, :rule, :name
          base.send :validates_presence_of, :abstractor_rule_abstractor_subjects, unless: :marked_for_soft_delete?

          # Hooks
          base.send :after_validation, :set_abstractor_subjects_not_deleted_ids_errors
          base.send :before_save,   :set_soft_delete_abstractor_rule_abstractor_subjects
          base.send :before_save,   :soft_delete_abstractor_rule_abstractor_subjects
          base.send :after_update,  :update_abstractor_rule_abstractor_subjects
          base.send :after_touch,   :update_abstractor_rule_abstractor_subjects

          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)
        end

        module InstanceMethods
          def abstractor_subjects_not_deleted_ids
            self.abstractor_rule_abstractor_subjects.not_deleted.map(&:abstractor_subject_id)
          end

          def abstractor_subjects_not_deleted_ids=(ids=[])
            # Workaround soft deletion, in normal case passing abstractor_subject_ids works out of the box
            existing_subject_ids  = self.abstractor_subjects_not_deleted_ids
            passed_subject_ids    = ids.select(&:present?).map(&:to_i)
            added_subject_ids     = passed_subject_ids    - existing_subject_ids
            removed_subject_ids   = existing_subject_ids  - passed_subject_ids

            added_subject_ids.map{|id| self.abstractor_rule_abstractor_subjects.build(abstractor_subject_id: id)}
            self.abstractor_rule_abstractor_subjects.select{|r| removed_subject_ids.include?(r.abstractor_subject_id)}.map(&:mark_for_destruction)
          end

          def set_abstractor_subjects_not_deleted_ids_errors
            self.errors.messages[:abstractor_subjects_not_deleted_ids] = self.errors.messages[:abstractor_rule_abstractor_subjects]
          end

          def set_soft_delete_abstractor_rule_abstractor_subjects
            self.abstractor_rule_abstractor_subjects.select(&:marked_for_destruction?).map(&:reload).map(&:process_soft_delete)
          end

          def soft_delete_abstractor_rule_abstractor_subjects
            if self.marked_for_soft_delete?
              self.abstractor_rule_abstractor_subjects.not_deleted.map(&:soft_delete!)
            end
          end

          def update_abstractor_rule_abstractor_subjects
            self.abstractor_rule_abstractor_subjects.reject(&:new_record?).map(&:touch)
          end

          def marked_for_soft_delete?
            self.deleted_at.present? && self.deleted_at_changed?
          end
        end

        module ClassMethods
          def search_by_abstractor_subjects_ids(abstractor_subject_ids)
            Abstractor::AbstractorRule.not_deleted.where(['EXISTS(SELECT 1 FROM abstractor_rule_abstractor_subjects WHERE abstractor_rules.id = abstractor_rule_abstractor_subjects.abstractor_rule_id AND abstractor_rule_abstractor_subjects.deleted_at IS NULL AND abstractor_rule_abstractor_subjects.abstractor_subject_id IN(?))', abstractor_subject_ids])
          end

          def search_across_fields(query)
            if query.blank?
              all
            else
              where("LOWER(rule) LIKE ?", "%#{query.downcase}%")
            end
          end
        end
      end
    end
  end
end