# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    phone_number
    after(:create) do |user|
      create(:user_device, user: user) if user.user_devices.blank?
    end
  end
end
