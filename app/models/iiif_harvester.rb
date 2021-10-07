# frozen_string_literal: true

# harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
# Note: IIIF API : http://iiif.io/api/presentation/2.0
class IiifHarvester < Spotlight::Resources::IiifHarvester

  self.document_builder_class = ::IiifBuilder

  def iiif_manifests
    @iiif_manifests ||= ::IiifService.parse(url)
  end

  def document_builder
    builder = super
    builder.total = ::IiifService.get_total(url)
    builder
  end
end
