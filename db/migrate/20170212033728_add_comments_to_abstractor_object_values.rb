class AddCommentsToAbstractorObjectValues < ActiveRecord::Migration
  def change
    add_column :abstractor_object_values, :comments, :text
  end
end
