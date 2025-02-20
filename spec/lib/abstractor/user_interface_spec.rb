require 'spec_helper'
describe Abstractor::UserInterface do
  it "prepends a relative url if the path does not include the root and is set ", focus: false do
    allow(Dummy::Application.config.action_controller).to receive(:relative_url_root).and_return('/dummy')
    expect(Abstractor::UserInterface.abstractor_relative_path('/encounter_notes')).to eq('/dummy/encounter_notes')
  end

  it "does not prepend a relative url root if the path does include the root (event if it is set) ", focus: false do
    allow(Dummy::Application.config.action_controller).to receive(:relative_url_root).and_return('/dummy')
    expect(Abstractor::UserInterface.abstractor_relative_path('/dummy/encounter_notes')).to eq('/dummy/encounter_notes')
  end

  it "does not prepend a relative url root if is not set", focus: false do
    allow(Dummy::Application.config.action_controller).to receive(:relative_url_root).and_return(nil)
    expect(Abstractor::UserInterface.abstractor_relative_path('/encounter_notes')).to eq('/encounter_notes')
  end

  it 'generates a source id', focus: false do
    source = {}
    source[:source_type] = 'Moomin'
    source[:source_id] = 1
    source[:source_method] = 'note_text'
    expect(Abstractor::UserInterface.generate_source_id(source)).to eq("Moomin_1_note_text")
  end
end
