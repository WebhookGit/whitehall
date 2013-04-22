require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  # re-using an existing table to make these tests much clearer
  # as all the searchable definition is in one place (and it doesn't
  # lend itself to redefinition)
  class SearchableTestTopic < ActiveRecord::Base
    self.table_name = 'classifications'
    include Searchable
    searchable(
      link: :name,
      only: :published,
      index_after: [:save],
      unindex_after: [:destroy]
    )
    scope :published, where(state: 'published')
  end

  def setup
    Whitehall.stubs(:searchable_classes).returns([SearchableTestTopic])
  end

  test 'will not request indexing on save if it is not contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.new(name: 'woo', state: 'draft')
    Searchable::Index.expects(:later).never
    s.save
  end

  test 'will request indexing on save if it is contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.new(name: 'woo', state: 'published')
    Searchable::Index.expects(:later).with(s)
    s.save
  end

  test 'will request deletion on destruction even if it is not contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Searchable::Delete.expects(:later).with(s)
    s.destroy
  end

  test 'will request deletion on destruction if it is contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Searchable::Delete.expects(:later).with(s)
    s.destroy
  end

  test 'will only request indexing of things that are included in the searchable_classes property' do
    class NonExistentClass; end
    Whitehall.stubs(:searchable_classes).returns([NonExistentClass])
    s = SearchableTestTopic.new(name: 'woo', state: 'published')
    Searchable::Index.expects(:later).never
    s.save
  end

  test 'Index.later will enqueue an indexing job with the class and id' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Searchable::Index.expects(:new).with('SearchableTest::SearchableTestTopic', s.id).returns :an_indexing_job
    Delayed::Job.expects(:enqueue).with :an_indexing_job
    Searchable::Index.later(s)
  end

  test 'Delete.later will enqueue an indexing job with the link for the object and the index to remove it from' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Searchable::Delete.expects(:new).with(s.name, Whitehall.government_search_index_path).returns :a_deletion_job
    Delayed::Job.expects(:enqueue).with :a_deletion_job
    Searchable::Delete.later(s)
  end

  test 'Index#perform will raise if the supplied class name is not searchable' do
    class NonExistentClass; end
    Whitehall.stubs(:searchable_classes).returns([NonExistentClass])
    index_job = Searchable::Index.new('SearchableTest::SearchableTestTopic', 2_000)
    assert_raises(ArgumentError) { index_job.perform }
  end

  test 'Index#perform will raise if the supplied object does not exist' do
    index_job = Searchable::Index.new('SearchableTest::SearchableTestTopic', 2_000)
    assert_raises(ActiveRecord::RecordNotFound) { index_job.perform }
  end

  test 'Index#perform will not index the object if it is not contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Rummageable.expects(:index).never
    index_job = Searchable::Index.new(s.class.name, s.id)
    index_job.perform
  end

  test 'Index#perform will index the object if it is contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Rummageable.expects(:index).with(s.search_index, Whitehall.government_search_index_path).once
    index_job = Searchable::Index.new(s.class.name, s.id)
    index_job.perform
  end

  test 'Delete#perform will remove the link from the index' do
    Rummageable.expects(:delete).with('woo', Whitehall.government_search_index_path).once
    delete_job = Searchable::Delete.new('woo', Whitehall.government_search_index_path)
    delete_job.perform
  end

end
