class CreateAbstractorSuggestionObjectValueVariants < ActiveRecord::Migration
  def change
    create_table :abstractor_suggestion_object_value_variants do |t|
      t.integer :abstractor_suggestion_id
      t.integer :abstractor_object_value_variant_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
