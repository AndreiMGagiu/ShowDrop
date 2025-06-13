FactoryBot.define do
  factory :distributor do
    name { Faker::Company.name }
    country { Faker::Address.country_code }
    kind { %w[network web_channel].sample }
  end
end
