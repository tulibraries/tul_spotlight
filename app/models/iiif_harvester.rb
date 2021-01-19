# frozen_string_literal: true

# harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
# Note: IIIF API : http://iiif.io/api/presentation/2.0
class IiifHarvester < Spotlight::Resources::IiifHarvester

  def iiif_manifests
    @iiif_manifests ||= ::IiifService.parse(url)
  end
end
