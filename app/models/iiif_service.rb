# frozen_string_literal: true

class IiifService < Spotlight::Resources::IiifService

  def manifests
    @manifests ||= if manifest?
                     [create_iiif_manifest(object)]
                   elsif object.respond_to? :manifests
                     object.manifests.map { |manifest|
                       create_iiif_manifest(manifest)
                     }
                   else
                     build_collection_manifest.to_a
                   end
  end

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

  def self.get_total(url)
    new(url).total
  end
end
