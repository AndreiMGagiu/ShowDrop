# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'database columns' do
    it { is_expected.to have_db_column(:email).of_type(:string).with_options(null: false, default: '') }
    it { is_expected.to have_db_column(:encrypted_password).of_type(:string).with_options(null: false, default: '') }
    it { is_expected.to have_db_column(:reset_password_token).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_sent_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:jti).of_type(:string).with_options(null: false) }
  end

  describe 'database indexes' do
    it { is_expected.to have_db_index(:email).unique(true) }
    it { is_expected.to have_db_index(:reset_password_token).unique(true) }
    it { is_expected.to have_db_index(:jti).unique(true) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password).on(:create) }
  end

  describe 'Devise modules' do
    it { expect(described_class.devise_modules).to include(:database_authenticatable) }
    it { expect(described_class.devise_modules).to include(:registerable) }
    it { expect(described_class.devise_modules).to include(:validatable) }
    it { expect(described_class.devise_modules).to include(:jwt_authenticatable) }
  end
end
