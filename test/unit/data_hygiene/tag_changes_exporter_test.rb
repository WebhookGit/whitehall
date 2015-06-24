require "test_helper"
require "data_hygiene/tag_changes_exporter"

class TagChangesExporterTest < ActiveSupport::TestCase
  include DataHygiene

  def setup
    @csv_file = Tempfile.new('tag_changes')
    @topic_id_to_add = "the-new-policy-area"
    @topic_id_to_remove = "the-old-policy-area"
    @publication = create :publication, :published, primary_specialist_sector_tag: @topic_id_to_remove
    @second_publication = create :publication, :published, primary_specialist_sector_tag: @topic_id_to_remove
    @third_publication = create :publication, :published, primary_specialist_sector_tag: @topic_id_to_add
  end

  def tear_down
    @csv_file.unlink
  end

  test "#export - exports the tag changes to make in CSV format" do
    TagChangesExporter.new(@csv_file.path, @topic_id_to_remove, @topic_id_to_add).export

    assert_equal expected_parsed_export, parsed_export
  end

  def expected_parsed_export
    [
      {
        "document_id" => @publication.document.id.to_s,
        "document_type" => @publication.document.document_type,
        "slug" => @publication.slug,
        "add_policy_area" => "the-new-policy-area",
        "remove_policy_area" => "the-old-policy-area"
      },
      {
        "document_id" => @second_publication.document.id.to_s,
        "document_type" => @second_publication.document.document_type,
        "slug" => @second_publication.slug,
        "add_topic_area" => "the-new-topic-area",
        "remove_topic_area" => "the-old-topic-area"
      }
    ]
  end

  def parsed_export
    parsed = []
    CSV.foreach(@csv_file.path, headers: true) do |data|
      parsed << data.to_hash
    end
    parsed
  end
end
