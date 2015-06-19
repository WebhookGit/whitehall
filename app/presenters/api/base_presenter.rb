Api::BasePresenter = Struct.new(:model, :context) do
  def self.paginate(collection, view_context)
    page = Api::Paginator.paginate(collection, view_context.params)
    collection = Whitehall::Decorators::CollectionDecorator.new(page, self, view_context)
    Api::PagePresenter.new(collection, view_context)
  end
end
