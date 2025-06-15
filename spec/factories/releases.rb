FactoryBot.define do
  factory :release do
    episode_id { Faker::Number.unique.number(digits: 6) }
    episode_name { "Episode #{Faker::Number.between(from: 1, to: 300)}" }
    airdate { Faker::Date.forward(days: 30) }
    airstamp { airdate.to_datetime.change(hour: 21) }
    runtime { [ 30, 60, 90, 180 ].sample }
    season { Faker::Number.between(from: 1, to: 20) }
    number { Faker::Number.between(from: 1, to: 200) }

    association :tv_show
    association :distributor
  end
end
