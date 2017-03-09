class AddCaseSensitiveToAbstractorObjectValues < ActiveRecord::Migration
  def change
    add_column :abstractor_object_values, :case_sensitive, :boolean, default: false
  end
end
