# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  include Spotlight::SolrDocument

  include Spotlight::SolrDocument::AtomicUpdates


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
end


module Spotlight
  module Resources
    class IiifManifest
      def add_thumbnail_url
        unless thumbnail_field && manifest['thumbnail'].present?
          unless full_image_url.nil?
            uri = URI(full_image_url)
            path = uri.path.split("/")
            thumbnail = "http://digital.library.temple.edu/utils/getthumbnail/collection/#{path[3]}/id/#{path[4]}"
            solr_hash[thumbnail_field] = thumbnail
          end
        else
          solr_hash[thumbnail_field] = manifest['thumbnail']['@id']
        end
      end
    end
  end
end
