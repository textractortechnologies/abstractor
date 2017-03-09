class AddCaseSensitiveToAbstractorObjectValueVariants < ActiveRecord::Migration
  def change
    add_column :abstractor_object_value_variants, :case_sensitive, :boolean, default: false
  end
end