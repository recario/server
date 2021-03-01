# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(KnownNumbersFiltered) do
  let(:user) { create(:user) }
  let!(:friend) { create(:user) }
  let(:friend_of_friend) { create(:user) }

  before do
    create_list(:user_contact, 3, user: friend)
    create_list(:user_contact, 3, user: friend_of_friend)

    create_list(:user_contact, 3, user: user)
    create(:user_contact, user: user, phone_number: friend.phone_number)
  end

  it 'shows friends contacts' do
    expected_phone_numbers = [
      friend.user_contacts.map(&:phone_number_id),
      friend.phone_number_id,
    ].flatten
    result = PhoneNumber.find_by_sql(subject.call(user_phone_number_id: user.phone_number_id, friend_phone_number_ids: friend.phone_number_id)).map(&:phone_number_id)
    expect(result).to(match_array(expected_phone_numbers))
  end

  it 'shows friends of friends contacts' do
    create(:user_contact, user: friend, phone_number: friend_of_friend.phone_number)

    expected_phone_numbers = [
      friend.user_contacts.map(&:phone_number_id),
      friend_of_friend.user_contacts.map(&:phone_number_id),
      friend.phone_number_id,
    ].flatten
    result = PhoneNumber.find_by_sql(subject.call(user_phone_number_id: user.phone_number_id, friend_phone_number_ids: friend.phone_number_id)).map(&:phone_number_id)
    expect(result).to(match_array(expected_phone_numbers))
  end

  it 'does not show my contacts' do
    not_expected_phone_numbers = [
      user.phone_number_id,
    ].flatten
    result = PhoneNumber.find_by_sql(subject.call(user_phone_number_id: user.phone_number_id, friend_phone_number_ids: friend.phone_number_id)).map(&:phone_number_id)
    expect(result).to_not(include(*not_expected_phone_numbers))
  end
end
