class AddWorkflowStatusFields < ActiveRecord::Migration
  def change
    add_column :abstractor_subject_groups, :enable_workflow_status, :boolean, default: false
    add_column :abstractor_subject_groups, :workflow_status_submit, :string
    add_column :abstractor_subject_groups, :workflow_status_pend, :string
    add_column :abstractor_abstractions, :workflow_status, :string
  end
end
