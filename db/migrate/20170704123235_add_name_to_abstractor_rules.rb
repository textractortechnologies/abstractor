class AddNameToAbstractorRules < ActiveRecord::Migration
  def change
    add_column :abstractor_rules, :name, :string
  end
end
