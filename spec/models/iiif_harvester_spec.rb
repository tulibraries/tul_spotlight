# frozen_string_literal: true

require 'rails_helper'

describe ::IiifHarvester do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:harvester) { described_class.create(exhibit_id: exhibit.id, url: url) }

  describe '#documents_to_index' do
    subject { harvester.document_builder }

    let(:url) { 'https://digital.library.temple.edu/iiif/info/p16002coll4/manifest.json' }

    it 'returns an Enumerator of all the solr documents' do
      VCR.use_cassette("p16002coll4_manifests") do
        enum = subject.documents_to_index
        expect(enum).to be_a(Enumerator)
        expect(enum.count).to eq 142
        expect(enum.size).to eq 142
      end
    end

    it 'captures CDM metadata in the solr document' do
      VCR.use_cassette("p16002coll4_manifests") do
        enum = subject.documents_to_index
        first_doc = enum.to_a[0]
        expect(first_doc['full_title_tesim']).to eq '[Letter of 1866 April 30]'
        expect(first_doc[:full_image_url_ssm]).to eq 'https://cdm16002.contentdm.oclc.org/digital/iiif/p16002coll4/0/full/full/0/default.jpg'
      end
    end
  end

  describe 'paginated collections' do
    subject { harvester.document_builder }

    let(:url) { 'https://digital.library.temple.edu/iiif/info/p16002coll2/manifest.json' }

    it 'returns an Enumerator of all the solr documents' do
      VCR.use_cassette("p16002coll2_manifests") do
        expect(subject.documents_to_index).to be_a(Enumerator)
        expect(subject.documents_to_index.count).to eq 2314
      end
    end
  end
end
