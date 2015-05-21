class AddAcceptedToAbstractorSuggestions < ActiveRecord::Migration
  def change
    add_column :abstractor_suggestions, :accepted, :boolean
    remove_column :abstractor_suggestions, :abstractor_suggestion_status_id
    drop_table :abstractor_suggestion_statuses
  end
end
