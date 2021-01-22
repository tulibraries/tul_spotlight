# frozen_string_literal: true

# harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
# Note: IIIF API : http://iiif.io/api/presentation/2.0
class IiifBuilder < Spotlight::Resources::IiifBuilder

  alias_method :documents_to_index_orig, :documents_to_index

  delegate :total, to: :resource

  def documents_to_index
    return to_enum(:documents_to_index_orig) { total } unless block_given?
    documents_to_index_orig.call(&block)
  end
end
