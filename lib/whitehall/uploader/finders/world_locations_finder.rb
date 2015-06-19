class Whitehall::Uploader::Finders::WorldLocationsFinder
  def self.find(*slugs, logger, line_number)
    slugs = slugs.reject(&:blank?)

    world_locations = slugs.map do |slug|
      world_location = WorldLocation.find_by(slug: slug)
      logger.error "Unable to find WorldLocation with slug '#{slug}'", line_number unless world_location
      world_location
    end.compact
  end
end
