# frozen_string_literal: true

class IiifService < Spotlight::Resources::IiifService

  def self.recursive_manifests(thing, &block)
    return to_enum(:recursive_manifests, thing) unless block_given?
    thing.manifests.each(&block)

    thing.collections.each do |collection|
      recursive_manifests(collection, &block)
    end

    thing.with_each_page do |page_thing|
      recursive_manifests(page_thing, &block)
    end
  end

  def with_each_page
    return unless collection?
    %w(first next).each do |pointer|
      next_page_url = object.to_ordered_hash.dig(pointer, "@id")
      yield self.class.new(next_page_url) if next_page_url
    end
  end

  def total
    object['total']
  end

  def build_collection_manifest
    return to_enum(:build_collection_manifest) unless block_given?

    (object.try(:manifests) || []).each do |manifest|
      yield create_iiif_manifest(self.class.new(manifest['@id']).object)
    end
  end
end
