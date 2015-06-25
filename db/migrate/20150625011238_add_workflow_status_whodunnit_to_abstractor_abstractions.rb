class AddWorkflowStatusWhodunnitToAbstractorAbstractions < ActiveRecord::Migration
  def change
    add_column :abstractor_abstractions, :workflow_status_whodunnit, :string
  end
end
