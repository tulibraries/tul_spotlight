# frozen_string_literal: true

require 'rails_helper'

describe ::IiifHarvester do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:harvester) { described_class.create(exhibit_id: exhibit.id, url: url) }

  describe '#documents_to_index' do
    subject { harvester.document_builder }

    let(:url) { 'https://digital.library.temple.edu/iiif/info/p16002coll4/manifest.json' }

    it 'returns an Enumerator of all the solr documents' do
      VCR.use_cassette("p16002coll4_manifests", :allow_playback_repeats => true) do
        enum = subject.documents_to_index
        expect(enum).to be_a(Enumerator)
        expect(enum.count).to eq 142
        expect(enum.size).to eq 142
      end
    end
  end

  describe 'paginated collections' do
    subject { harvester.document_builder }

    let(:url) { 'https://digital.library.temple.edu/iiif/info/p16002coll2/manifest.json' }

    it 'returns an Enumerator of all the solr documents' do
      VCR.use_cassette("p16002coll2_manifests", :allow_playback_repeats => true) do
        expect(subject.documents_to_index).to be_a(Enumerator)
        expect(subject.documents_to_index.count).to eq 2314
      end
    end
  end
end
