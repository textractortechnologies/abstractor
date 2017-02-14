require 'spec_helper'
describe  Abstractor::AbstractorObjectValue do
  before(:each) do
    Abstractor::Setup.system
  end

  let(:abstractor_object_type)        { Abstractor::AbstractorObjectType.all.sample }
  let(:abstractor_object_value)       { FactoryGirl.create(:abstractor_object_value, value: 'foo') }
  let(:abstractor_abstraction_schema) { FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property') }

  it "is valid with valid attributes" do
    expect(abstractor_object_value).to be_valid
  end

  it "is invalid with invalid attributes" do
    abstractor_object_value.value = nil
    abstractor_object_value.vocabulary_code = nil
    abstractor_object_value.vocabulary = nil
    abstractor_object_value.vocabulary_version = nil

    expect(abstractor_object_value).not_to be_valid
    expect(abstractor_object_value.errors.full_messages).to include("Value can't be blank")
  end

  it "can report its object variants" do
    abstractor_abstraction_schema.abstractor_object_values << FactoryGirl.build(:abstractor_object_value, value: 'foo')
    FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: abstractor_abstraction_schema.abstractor_object_values.first, value: 'boo')
    expect(Set.new(abstractor_abstraction_schema.abstractor_object_values.first.object_variants)).to eq(Set.new(['foo', 'boo']))
  end

  it 'updates timestamp on linked schemas on update' do
    abstractor_abstraction_schema_object_value            = Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_abstraction_schema_timestamp               = abstractor_abstraction_schema.updated_at
    abstractor_abstraction_schema_object_value_timestamp  = abstractor_abstraction_schema_object_value.updated_at

    abstractor_object_value.value = 'boo'
    abstractor_object_value.save!

    expect(abstractor_abstraction_schema.reload.updated_at).to              be > abstractor_abstraction_schema_timestamp
    expect(abstractor_abstraction_schema_object_value.reload.updated_at).to be > abstractor_abstraction_schema_object_value_timestamp
  end

  it 'updates timestamp on linked schemas on destroy' do
    abstractor_abstraction_schema_object_value            = Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_abstraction_schema_timestamp               = abstractor_abstraction_schema.updated_at
    abstractor_abstraction_schema_object_value_timestamp  = abstractor_abstraction_schema_object_value.updated_at

    abstractor_object_value.destroy

    expect(abstractor_abstraction_schema.reload.updated_at).to              be > abstractor_abstraction_schema_timestamp
    expect(abstractor_abstraction_schema_object_value.reload.updated_at).to be > abstractor_abstraction_schema_object_value_timestamp
  end
end
