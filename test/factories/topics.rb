FactoryGirl.define do
  factory :topic do
    sequence(:name) { |index| "policy-area-#{index}" }
    description 'Policy area description'
  end
end
