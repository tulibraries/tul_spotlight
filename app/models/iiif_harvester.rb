# frozen_string_literal: true

# harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
# Note: IIIF API : http://iiif.io/api/presentation/2.0
class IiifHarvester < Spotlight::Resources::IiifHarvester

  self.document_builder_class = ::IiifBuilder

  # We don't use the IiifService.parse method because
  # we want to get the total for the set before we start
  # retrieving all the pages

  def iiif_service
    @iiif_service ||= ::IiifService.new(url)
  end

  def iiif_manifests
    @iiif_manifests ||= ::IiifService.recursive_manifests(iiif_service)
  end

  def total
    iiif_service.total
  end
end
