class AddDescriptionToAbstractorRules < ActiveRecord::Migration
  def change
    add_column :abstractor_rules, :description, :string
  end
end
