module Edition::Topics
  extend ActiveSupport::Concern
  include Edition::Classifications

  included do
    has_many :topics, through: :classification_memberships, source: :topic
    validate :has_at_least_one_topic, unless: :imported?
  end

  def can_be_associated_with_topics?
    true
  end

  def search_index
    super.merge("topics" => topics.map(&:slug)) { |_, ov, nv| ov + nv }
  end

  def title_with_topics
    "#{title} (#{topics.map(&:name).to_sentence})"
  end

  module ClassMethods
    def in_topic(topic)
      joins(:classification_memberships).where("classification_memberships.classification_id" => topic)
    end

    def published_in_topic(topic)
      published.in_topic(topic)
    end

    def scheduled_in_topic(topic)
      scheduled.in_topic(topic)
    end
  end

private

  def has_at_least_one_topic
    # We need to check the join model because policy areas will be empty until the
    # classification memberships records are saved, which won't happen until
    # the parent policy area is valid. We need to use #empty? here as ActiveRecord
    # overrides it to avoid caching the policy areas association.
    if classification_memberships.empty? && topics.empty?
      errors.add(:topics, "at least one required")
    end
  end
end
