FactoryBot.define do
  factory :tv_show do
    provider_identifier { Faker::Number.unique.number(digits: 5) }
    name { Faker::TvShows::GameOfThrones.character }
    language { "English" }
    status { "Running" }
    rating { rand(5.0..9.5).round(1) }
    summary { Faker::Lorem.paragraph }
    image { Faker::Internet.url }
  end
end
