class CreateAbstractorRules < ActiveRecord::Migration
  def change
    create_table :abstractor_rules do |t|
      t.text :rule,             null: false
      t.datetime :deleted_at,   null: true

      t.timestamps
    end
  end
end


