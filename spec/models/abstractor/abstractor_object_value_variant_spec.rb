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

  describe 'deleting an abstractor object value variant' do
    before(:each) do
      Setup.sites
      Setup.custom_site_synonyms
      Setup.site_categories
      Setup.laterality
      Abstractor::Setup.system
      Setup.radiation_therapy_prescription
      @abstractor_abstraction_schema_has_anatomical_location = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_anatomical_location').first
      @abstractor_subject_abstraction_schema_has_anatomical_location = Abstractor::AbstractorSubject.where(subject_type: RadiationTherapyPrescription.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_has_anatomical_location.id).first
      @abstractor_object_value = @abstractor_abstraction_schema_has_anatomical_location.abstractor_object_values.where(value: 'parietal lobe').first
      @abstractor_object_value_variant = @abstractor_object_value.abstractor_object_value_variants.where(value: 'parietal').first
    end

    it 'knows if an abstractor object value varaint is used by having an abstractor suggestion', focus: false do
      expect(@abstractor_object_value_variant.used?).to be_falsy
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract
      expect(@abstractor_object_value_variant.reload.used?).to be_truthy
    end

    it 'cascade soft deletes unaccepted abstractor suggestions upon soft delete of an abstractor object value variant', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract

      abstractor_abstraction = radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_has_anatomical_location)
      abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.not_deleted.where(suggested_value: @abstractor_object_value.value).first
      expect(abstractor_suggestion).to_not be_nil
      expect(abstractor_suggestion.abstractor_object_value_variants.detect { |abstractor_object_value_variant| abstractor_object_value_variant == @abstractor_object_value_variant }).to be_truthy
      @abstractor_object_value_variant.soft_delete!
      abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.deleted.where(suggested_value: @abstractor_object_value.value).first
      expect(abstractor_suggestion).to_not be_nil
    end

    it 'does not cascade soft deletes accepted abstractor suggestions upon soft delete of an abstractor object value variant', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract

      abstractor_abstraction = radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_has_anatomical_location)
      abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.not_deleted.where(suggested_value: @abstractor_object_value.value).first
      abstractor_suggestion.accepted = true
      abstractor_suggestion.save!
      expect(abstractor_suggestion).to_not be_nil
      expect(abstractor_suggestion.abstractor_object_value_variants.detect { |abstractor_object_value_variant| abstractor_object_value_variant == @abstractor_object_value_variant }).to be_truthy
      @abstractor_object_value_variant.soft_delete!
      abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.deleted.where(suggested_value: @abstractor_object_value.value).first
      expect(abstractor_suggestion).to be_nil
      abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.not_deleted.where(suggested_value: @abstractor_object_value.value).first
      expect(abstractor_suggestion).to_not be_nil
    end

    it 'cascade soft deletes unaccepted abstractor suggestions upon soft delete of an abstractor object value variant and create and unknonw suggestion if no more suggestions remain', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract

      abstractor_abstraction = radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_has_anatomical_location)
      expect(abstractor_abstraction.abstractor_suggestions.not_deleted.select { |abstractor_suggestion| abstractor_suggestion.unknown == true }.empty?).to be_truthy
      abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.not_deleted.where(suggested_value: @abstractor_object_value.value).first
      expect(abstractor_suggestion).to_not be_nil
      expect(abstractor_suggestion.abstractor_object_value_variants.detect { |abstractor_object_value_variant| abstractor_object_value_variant == @abstractor_object_value_variant }).to be_truthy
      @abstractor_object_value_variant.soft_delete!
      abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.deleted.where(suggested_value: @abstractor_object_value.value).first
      expect(abstractor_suggestion).to_not be_nil
      expect(abstractor_abstraction.abstractor_suggestions.not_deleted.select { |abstractor_suggestion| abstractor_suggestion.unknown == true }.empty?).to be_falsy
    end
  end
end