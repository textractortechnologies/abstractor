require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe RadiationTherapyPrescription do
  before(:each) do
    Setup.sites
    Setup.custom_site_synonyms
    Setup.site_categories
    Setup.laterality
    Abstractor::Setup.system
    Setup.radiation_therapy_prescription
    @abstractor_abstraction_schema_has_anatomical_location = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_anatomical_location').first
    @abstractor_abstraction_schema_has_laterality = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_laterality').first
    @abstractor_abstraction_schema_has_radiation_therapy_prescription_date = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_radiation_therapy_prescription_date').first
    @abstractor_subject_abstraction_schema_has_anatomical_location = Abstractor::AbstractorSubject.where(subject_type: RadiationTherapyPrescription.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_has_anatomical_location.id).first
    @abstractor_subject_abstraction_schema_has_laterality = Abstractor::AbstractorSubject.where(subject_type: RadiationTherapyPrescription.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_has_laterality.id).first
    @abstractor_subject_abstraction_schema_has_radiation_therapy_prescription_date = Abstractor::AbstractorSubject.where(subject_type: RadiationTherapyPrescription.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_has_radiation_therapy_prescription_date.id).first
    @anatomical_location_subject_group  = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
  end

  before(:each) do
    @radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription)
  end

  describe "abstracting" do
    it "can report its abstractor subject groups" do
      abstractor_subject_groups = Abstractor::AbstractorSubjectGroup.where(name:'Anatomical Location')
      expect(RadiationTherapyPrescription.abstractor_subject_groups).to_not be_empty
      expect(Set.new(RadiationTherapyPrescription.abstractor_subject_groups)).to eq(Set.new(abstractor_subject_groups))
    end

    #abstractions
    it "creates a 'has_anatomical_location' abstraction'" do
      @radiation_therapy_prescription.abstract
      expect(@radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location)).to_not be_nil
    end

    it "does not create another 'has_anatomical_location' abstraction upon re-abstraction" do
      @radiation_therapy_prescription.abstract
      expect(@radiation_therapy_prescription.reload.abstractor_abstractions.select { |abstraction| abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == 'has_anatomical_location' }.size).to eq(1)
    end

    it "creates a 'has_laterality' abstraction'" do
      @radiation_therapy_prescription.abstract
      expect(@radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_laterality)).to_not be_nil
    end

    it "does not create another 'has_laterality' abstraction upon re-abstraction" do
      @radiation_therapy_prescription.abstract
      expect(@radiation_therapy_prescription.reload.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == 'has_laterality' }.size).to eq(1)
    end

    #suggestion suggested value
    it "creates a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.suggested_value).to eq('parietal lobe')
    end

    it "creates a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value variant" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.suggested_value).to eq('parietal lobe')
    end

    it "creates an association to the abstractor object value variant for a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value variant", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract
      abstractor_abstraction = radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location)
      abstractor_object_value = @abstractor_abstraction_schema_has_anatomical_location.abstractor_object_values.where(value: 'parietal lobe').first
      abstractor_object_value_variant = abstractor_object_value.abstractor_object_value_variants.where(value: 'parietal').first
      expect(abstractor_abstraction.abstractor_suggestions.first.abstractor_object_value_variants.first).to eq(abstractor_object_value_variant)
    end

    it "creates an association to the abstractor object value variant for a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value variant (but only one)", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Look at the cerebral cortex.  My goodness that is the Cerebral cortex.')
      radiation_therapy_prescription.abstract
      abstractor_abstraction = radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location)
      abstractor_object_value = @abstractor_abstraction_schema_has_anatomical_location.abstractor_object_values.where(value: 'cerebrum').first
      abstractor_object_value_variant = abstractor_object_value.abstractor_object_value_variants.where(value: 'cerebral cortex').first
      expect(abstractor_abstraction.abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(2)
      expect(abstractor_abstraction.abstractor_suggestions.first.abstractor_object_value_variants).to match_array([abstractor_object_value_variant])
    end

    it "creates an association to multiple abstractor object value variants for a 'has_anatomical_location' abstraction suggestion suggested value from multiple abstractor object value variants", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Look at the cerebral cortex.  My goodness that is the internal capsule.')
      radiation_therapy_prescription.abstract
      abstractor_abstraction = radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location)
      abstractor_object_value = @abstractor_abstraction_schema_has_anatomical_location.abstractor_object_values.where(value: 'cerebrum').first
      abstractor_object_value_variant_1 = abstractor_object_value.abstractor_object_value_variants.where(value: 'cerebral cortex').first
      abstractor_object_value_variant_2 = abstractor_object_value.abstractor_object_value_variants.where(value: 'internal capsule').first
      expect(abstractor_abstraction.abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(2)
      expect(abstractor_abstraction.abstractor_suggestions.first.abstractor_object_value_variants).to match_array([abstractor_object_value_variant_1, abstractor_object_value_variant_2])
    end

    it "creates an association to the abstractor object value variant for a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value variant case insensitively", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left PARIETAL')
      radiation_therapy_prescription.abstract
      abstractor_abstraction = radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location)
      abstractor_object_value = @abstractor_abstraction_schema_has_anatomical_location.abstractor_object_values.where(value: 'parietal lobe').first
      abstractor_object_value_variant = abstractor_object_value.abstractor_object_value_variants.where(value: 'parietal').first
      expect(abstractor_abstraction.abstractor_suggestions.first.abstractor_object_value_variants.first).to eq(abstractor_object_value_variant)
    end

    it "creates a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value variant even if another synonym for the same term is negated", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Not in the thalamus.  But I think it is in the basal ganglia.')

      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.suggested_value).to eq('cerebrum')
    end

    #suggestion match value
    it "creates a 'has_anatomical_location' abstraction suggestion match value from a from an abstractor object value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('left parietal lobe')
    end

    it "creates a 'has_anatomical_location' abstraction suggestion match value from a from an abstractor object value variant" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('left parietal')
    end

    it "creates multiple 'has_anatomical_location' abstraction suggestion match values given multiple different matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Left parietal lobe.  Let me remind you that it is the left parietal.')
      radiation_therapy_prescription.abstract
      expect(Set.new(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.map(&:sentence_match_value))).to eq(Set.new(["left parietal lobe.", "let me remind you that it is the left parietal."]))
    end

    #suggestions
    it "does not create another 'has_anatomical_location' abstraction suggestion upon re-abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.size).to eq(1)
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.size).to eq(1)
    end

    it "creates multiple 'has_anatomical_location' abstraction suggestions given multiple different matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe and bilateral cerebral meninges')
      radiation_therapy_prescription.abstract

      expect(Set.new(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(['cerebral meninges', 'parietal lobe', 'meninges']))
    end

    it "creates one 'has_anatomical_location' abstraction suggestion given multiple identical matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Left parietal lobe.  Let me remend you that it is the left parietal lobe')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.suggested_value == 'parietal lobe'}.size).to eq(1)
    end

    #negation
    it "does not create a 'has_anatomical_location' abstraction suggestion match value from a negated value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Not the left parietal lobe.')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to be_nil
    end

    #suggestion sources
    it "creates one 'has_anatomical_location' abstraction suggestion source given multiple identical matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Left parietal lobe.  Talk about some other stuff.  Left parietal lobe.')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.abstractor_suggestion_sources.first.sentence_match_value == 'left parietal lobe.'}.size).to eq(1)
    end

    it "does not create another 'has_anatomical_location' abstraction suggestion source upon re-abstraction (using the canonical name/value format)" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
    end

    #abstractor object value
    it "creates a 'has_anatomical_location' abstraction suggestion object value for each suggestion with a suggested value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'parietal lobe').first
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_object_value).to eq(abstractor_object_value)
    end

    #unknowns
    it "creates a 'has_anatomical_location' unknown abstraction suggestion" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Forgot to mention an anatomical location.')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.unknown).to be_truthy
    end

    it "does not create a 'has_anatomical_location' abstraction suggestion object value for a unknown abstraction suggestion " do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Forgot to mention an anatomical location.')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_object_value).to be_nil
    end

    it "does not creates another 'has_anatomical_location' unknown abstraction suggestion upon re-abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Forgot to mention an anatomical location.')
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.unknown }.size).to eq(1)
      radiation_therapy_prescription.abstract
      expect(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.unknown }.size).to eq(1)
    end

    #groups
    it "creates a abstractor abstraction group" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.size).to eq(1)
    end

    it "does not creates another abstractor abstraction group upon re-abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      radiation_therapy_prescription.reload.abstract
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.size).to eq(1)
    end

    it "creates a abstractor abstraction group member for each abstractor abstraction", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first.abstractor_abstractions.size).to eq(3)
    end

    it "does not create duplicate abstractor abstraction grup members upon re-abstraction", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first.abstractor_abstractions.size).to eq(3)
    end

    it "creates a abstractor abstraction group member of the right kind for each abstractor abstraction", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      expect(Set.new(radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first.abstractor_abstractions.map(&:abstractor_abstraction_schema))).to eq(Set.new([@abstractor_abstraction_schema_has_anatomical_location, @abstractor_abstraction_schema_has_laterality, @abstractor_abstraction_schema_has_radiation_therapy_prescription_date]))
    end

    describe "updating all abstraction group members" do
      before(:each) do
        @radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
        @radiation_therapy_prescription.abstract
        abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
        @abstractor_abstraction_group = @radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first
      end

      it "to 'not applicable'", focus: false do
        expect(@abstractor_abstraction_group.abstractor_abstractions.map(&:not_applicable)).to eq([nil, nil, nil])
        Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@abstractor_abstraction_group.abstractor_abstractions, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE)
        expect(@abstractor_abstraction_group.reload.abstractor_abstractions.map(&:not_applicable)).to eq([true, true, true])
      end

      it "to 'unknown'", focus: false do
        expect(@abstractor_abstraction_group.abstractor_abstractions.map(&:unknown)).to eq([nil, nil, nil])
        Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@abstractor_abstraction_group.abstractor_abstractions, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN)
        expect(@abstractor_abstraction_group.reload.abstractor_abstractions.map(&:unknown)).to eq([true, true, true])
      end

      it "does not update more than necessary", focus: false do
        PaperTrail.enabled = true
        radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'vague blather')
        radiation_therapy_prescription.abstract
        abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
        abstractor_abstraction_group = radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first

        expect(abstractor_abstraction_group.abstractor_abstractions.map{ |aa| aa.versions.size }).to eq([1,1,1])
        Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(abstractor_abstraction_group.reload.abstractor_abstractions, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN)
        Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(abstractor_abstraction_group.reload.abstractor_abstractions, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE)
        expect(abstractor_abstraction_group.abstractor_abstractions.map{ |aa| aa.versions.size }).to eq([4,4,4])
        PaperTrail.enabled = false
      end

      it "rejects all abstraction suggestion statuses", focus: false do
        # rejected_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
        # needs_review_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Needs review').first
        abstractor_suggestions = @abstractor_abstraction_group.abstractor_abstractions.map(&:abstractor_suggestions).flatten
        expect(abstractor_suggestions.map(&:accepted)).to eq([nil, nil, nil])
        Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@abstractor_abstraction_group.abstractor_abstractions, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE)
        expect(abstractor_suggestions.each(&:reload).map(&:accepted)).to eq([false, false, false])
      end

      it "raises an error if passed an invalid argument", focus: false do
        expect{ Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value('little my') }.to raise_error(ArgumentError)
      end
    end

    #pivoting groups
    it "can pivot grouped abstractions as if regular columns on the abstractable entity", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      radiation_therapy_prescription.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.accepted = true
        abstractor_suggestion.save
      end

      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name:'Anatomical Location').first
      abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: abstractor_subject_group.id, about_type: RadiationTherapyPrescription.to_s, about_id: radiation_therapy_prescription.id)

      abstractor_subject_group.abstractor_subjects.each do |abstractor_subject|
        abstraction = abstractor_subject.abstractor_abstractions.build(about_id: radiation_therapy_prescription.id, about_type: RadiationTherapyPrescription.to_s)
        abstractor_abstraction_group.abstractor_abstractions << abstraction
      end
      abstractor_abstraction_group.save!

      pivots = RadiationTherapyPrescription.pivot_grouped_abstractions('Anatomical Location').where(id: radiation_therapy_prescription.id).map { |rtp| { id: rtp.id, site_name: rtp.site_name, has_laterality: rtp.has_laterality, has_anatomical_location: rtp.has_anatomical_location } }
      expect(Set.new(pivots)).to eq(Set.new([{ id: radiation_therapy_prescription.id, site_name: radiation_therapy_prescription.site_name, has_laterality: "left", has_anatomical_location: "parietal lobe" }, { id: radiation_therapy_prescription.id, site_name: radiation_therapy_prescription.site_name, has_laterality: nil, has_anatomical_location: nil }]))
    end

    it "can pivot grouped abstractions as if regular columns on the abstractable entity if the vaue is marked as 'unknown'", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      radiation_therapy_prescription.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.accepted = false
        abstractor_suggestion.save
        abstractor_abstraction.unknown = true
        abstractor_abstraction.save!
      end

      pivots = RadiationTherapyPrescription.pivot_grouped_abstractions('Anatomical Location').where(id: radiation_therapy_prescription.id).map { |rtp| { id: rtp.id, site_name: rtp.site_name, has_laterality: rtp.has_laterality, has_anatomical_location: rtp.has_anatomical_location } }
      expect(Set.new(pivots)).to eq(Set.new([{ id: radiation_therapy_prescription.id, site_name: radiation_therapy_prescription.site_name, has_laterality: 'unknown', has_anatomical_location: 'unknown' } ]))
    end

    it "can pivot grouped abstractions as if regular columns on the abstractable entity if the vaue is marked as 'not applicable'", focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      radiation_therapy_prescription.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.accepted = false
        abstractor_suggestion.save
        abstractor_abstraction.not_applicable = true
        abstractor_abstraction.save!
      end

      pivots = RadiationTherapyPrescription.pivot_grouped_abstractions('Anatomical Location').where(id: radiation_therapy_prescription.id).map { |rtp| { id: rtp.id, site_name: rtp.site_name, has_laterality: rtp.has_laterality, has_anatomical_location: rtp.has_anatomical_location } }
      expect(Set.new(pivots)).to eq(Set.new([{ id: radiation_therapy_prescription.id, site_name: radiation_therapy_prescription.site_name, has_laterality: 'not applicable', has_anatomical_location: 'not applicable' } ]))
    end

    describe "a mix of grouped and non-grouped abstractions" do
      before(:each) do
        string_object_type = Abstractor::AbstractorObjectType.where(value: 'string').first
        unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
        moomin_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_moomin', display_name: 'Moomin', abstractor_object_type: string_object_type, preferred_name: 'Moomin')
        abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'RadiationTherapyPrescription', :abstractor_abstraction_schema => moomin_abstraction_schema)
        @radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      end

      it "does not include grouped abstractions when pivoting non-grouped abstractions", focus: false do
        pivots = RadiationTherapyPrescription.pivot_abstractions.where(id: @radiation_therapy_prescription.id)
        expect(pivots.first).to respond_to(:has_moomin)
        expect(pivots.first).not_to respond_to(:has_laterality)
        expect(pivots.first).not_to respond_to(:has_anatomical_location)
      end

      it "does not include non-grouped abstractions when pivoting grouped abstractions", focus: false do
        @radiation_therapy_prescription.abstract
        pivots = RadiationTherapyPrescription.pivot_grouped_abstractions('Anatomical Location').where(id: @radiation_therapy_prescription.id)
        expect(pivots.first).not_to respond_to(:has_moomin)
        expect(pivots.first).to respond_to(:has_laterality)
        expect(pivots.first).to respond_to(:has_anatomical_location)
      end

      # abstractor subjects
      it "reports all abstractor subjects if the grouped options is not specified", focus: false do
        expect(RadiationTherapyPrescription.abstractor_subjects.size).to eq(4)
      end

      it "can report its grouped abstractor subjects", focus: false do
        expect(RadiationTherapyPrescription.abstractor_subjects(grouped: true).size).to eq(3)
      end

      it "can report its ungrouped abstractor subjects", focus: false do
        expect(RadiationTherapyPrescription.abstractor_subjects(grouped: false).size).to eq(1)
      end

      # abstraction schemas
      it "reports all abstractor subjects if the grouped options is not specified", focus: false do
        expect(RadiationTherapyPrescription.abstractor_abstraction_schemas.size).to eq(4)
      end

      it "can report its grouped abstraction schemas ", focus: false do
        expect(RadiationTherapyPrescription.abstractor_abstraction_schemas(grouped: true).size).to eq(3)
      end

      it "can report its ungrouped abstractor subjects", focus: false do
        expect(RadiationTherapyPrescription.abstractor_abstraction_schemas(grouped: false).size).to eq(1)
      end
    end

    it 'creates an abstraction group', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.size).to eq(1)

      Abstractor::AbstractorAbstractionGroup.create_abstractor_abstraction_group(@anatomical_location_subject_group.id, 'RadiationTherapyPrescription', radiation_therapy_prescription.id, nil, nil)
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.size).to eq(2)
    end

    it 'creates an abstraction group', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.size).to eq(1)

      Abstractor::AbstractorAbstractionGroup.create_abstractor_abstraction_group(@anatomical_location_subject_group.id, 'RadiationTherapyPrescription', radiation_therapy_prescription.id, nil, nil)
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.size).to eq(2)
    end

    it 'copies suggestions from the iniital group when creating an abstraction group', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.size).to eq(1)

      Abstractor::AbstractorAbstractionGroup.create_abstractor_abstraction_group(@anatomical_location_subject_group.id, 'RadiationTherapyPrescription', radiation_therapy_prescription.id, nil, nil)
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.size).to eq(2)

      suggestions_1 = radiation_therapy_prescription.abstractor_abstraction_groups.first.abstractor_abstractions.map(&:abstractor_suggestions).flatten
      suggestions_2 = radiation_therapy_prescription.abstractor_abstraction_groups.last.abstractor_abstractions.map(&:abstractor_suggestions).flatten
      expect(suggestions_1.size).to eq(suggestions_2.size)
      expect(suggestions_1.map(&:suggested_value)).to match_array(suggestions_2.map(&:suggested_value))
    end

    it 'finds abstractions by abstraction schema', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      abstractor_abstractions = radiation_therapy_prescription.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema == @abstractor_abstraction_schema_has_anatomical_location }
      expect(radiation_therapy_prescription.reload.abstractor_abstractions_by_abstraction_schemas(abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_has_anatomical_location.id])).to_not be_empty
      expect(radiation_therapy_prescription.reload.abstractor_abstractions_by_abstraction_schemas(abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_has_anatomical_location.id])).to eq(abstractor_abstractions)
    end

    it 'finds abstractions by abstraction schema within an abstraction group', focus: false do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract

      Abstractor::AbstractorAbstractionGroup.create_abstractor_abstraction_group(@anatomical_location_subject_group.id, 'RadiationTherapyPrescription', radiation_therapy_prescription.id, nil, nil)
      expect(radiation_therapy_prescription.reload.abstractor_abstraction_groups.size).to eq(2)

      abstractor_abstractions_group_1 = radiation_therapy_prescription.abstractor_abstraction_groups.first.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema == @abstractor_abstraction_schema_has_anatomical_location }
      abstractor_abstractions_group_2 = radiation_therapy_prescription.abstractor_abstraction_groups.last.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema == @abstractor_abstraction_schema_has_anatomical_location }
      expect(abstractor_abstractions_group_1).to_not be_empty
      expect(abstractor_abstractions_group_2).to_not be_empty
      expect(abstractor_abstractions_group_1).to_not eq (abstractor_abstractions_group_2)
      expect(radiation_therapy_prescription.reload.abstractor_abstractions_by_abstraction_schemas(abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_has_anatomical_location.id], abstractor_abstraction_group: radiation_therapy_prescription.abstractor_abstraction_groups.first)).to eq(abstractor_abstractions_group_1)
      expect(radiation_therapy_prescription.reload.abstractor_abstractions_by_abstraction_schemas(abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_has_anatomical_location.id], abstractor_abstraction_group: radiation_therapy_prescription.abstractor_abstraction_groups.last)).to eq(abstractor_abstractions_group_2)
    end
  end
end