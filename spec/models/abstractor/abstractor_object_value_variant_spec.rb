require 'spec_helper'
describe  Abstractor::AbstractorObjectValueVariant do
  before(:each) do
    Abstractor::Setup.system
    @abstractor_object_value = FactoryGirl.create(:abstractor_object_value, value: 'foo', vocabulary_code: 'foo')
  end

  let(:abstractor_object_type)          { Abstractor::AbstractorObjectType.all.sample }
  let(:abstractor_abstraction_schema)   { FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property') }

  it "is valid with valid attributes", focus: false do
    abstractor_object_value_variant = FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: @abstractor_object_value, value: @abstractor_object_value.value)
    expect(abstractor_object_value_variant).to be_valid
  end

  it "is invalid with invalid attributes", focus: false do
    abstractor_object_value_variant = FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: @abstractor_object_value, value: @abstractor_object_value.value)
    abstractor_object_value_variant.value = nil

    expect(abstractor_object_value_variant).not_to be_valid
    expect(abstractor_object_value_variant.errors.full_messages).to include("Value can't be blank")
  end

  it 'updates timestamp on linked schemas on create' do
    abstractor_abstraction_schema_object_value            = Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value)
    abstractor_abstraction_schema_timestamp               = abstractor_abstraction_schema.updated_at
    abstractor_abstraction_schema_object_value_timestamp  = abstractor_abstraction_schema_object_value.updated_at
    abstractor_object_value_timestamp                     = @abstractor_object_value.updated_at

    abstractor_object_value_variant = FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: @abstractor_object_value, value: @abstractor_object_value.value)

    expect(@abstractor_object_value.reload.updated_at).to                    be > abstractor_object_value_timestamp
    expect(abstractor_abstraction_schema_object_value.reload.updated_at).to be > abstractor_abstraction_schema_object_value_timestamp
    expect(abstractor_abstraction_schema.reload.updated_at).to              be > abstractor_abstraction_schema_timestamp
  end

  it 'updates timestamp on linked schemas on update' do
    abstractor_abstraction_schema_object_value            = Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value)
    abstractor_object_value_variant                       = FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: @abstractor_object_value, value: @abstractor_object_value.value)

    abstractor_abstraction_schema_timestamp               = abstractor_abstraction_schema.reload.updated_at
    abstractor_abstraction_schema_object_value_timestamp  = abstractor_abstraction_schema_object_value.reload.updated_at
    abstractor_object_value_timestamp                     = @abstractor_object_value.reload.updated_at

    abstractor_object_value_variant.value = 'zzz'
    abstractor_object_value_variant.save!

    expect(@abstractor_object_value.reload.updated_at).to                    be > abstractor_object_value_timestamp
    expect(abstractor_abstraction_schema_object_value.reload.updated_at).to be > abstractor_abstraction_schema_object_value_timestamp
    expect(abstractor_abstraction_schema.reload.updated_at).to              be > abstractor_abstraction_schema_timestamp
  end

  it 'updates timestamp on linked schemas on destroy' do
    abstractor_abstraction_schema_object_value            = Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value)
    abstractor_object_value_variant                       = FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: @abstractor_object_value, value: @abstractor_object_value.value)

    abstractor_abstraction_schema_timestamp               = abstractor_abstraction_schema.reload.updated_at
    abstractor_abstraction_schema_object_value_timestamp  = abstractor_abstraction_schema_object_value.reload.updated_at
    abstractor_object_value_timestamp                     = @abstractor_object_value.reload.updated_at

    abstractor_object_value_variant.destroy

    expect(@abstractor_object_value.reload.updated_at).to                    be > abstractor_object_value_timestamp
    expect(abstractor_abstraction_schema_object_value.reload.updated_at).to be > abstractor_abstraction_schema_object_value_timestamp
    expect(abstractor_abstraction_schema.reload.updated_at).to              be > abstractor_abstraction_schema_timestamp
  end
end
