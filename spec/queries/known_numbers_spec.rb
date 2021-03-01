# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(KnownNumbers) do
  let(:user) { create(:user) }
  let!(:my_contacts) { create_list(:user_contact, 3, user: user) }

  it 'shows my contacts' do
    expected_phone_numbers = my_contacts.map(&:phone_number_id)
    result = PhoneNumber.find_by_sql(subject.call(user.id)).map(&:phone_number_id)
    expect(result).to(match_array(expected_phone_numbers))
  end

  it 'shows my friend contacts' do
    friend = create(:user, phone_number: my_contacts.first.phone_number)
    create_list(:user_contact, 3, user: friend)

    expected_phone_numbers = my_contacts.map(&:phone_number_id).concat(friend.user_contacts.map(&:phone_number_id))
    result = PhoneNumber.find_by_sql(subject.call(user.id)).map(&:phone_number_id)
    expect(result).to(match_array(expected_phone_numbers))
  end

  it 'shows contacts of friends of my friend' do
    friend = create(:user, phone_number: my_contacts.first.phone_number)
    create_list(:user_contact, 3, user: friend)

    friend_of_friend = create(:user, phone_number: friend.user_contacts.first.phone_number)
    create_list(:user_contact, 3, user: friend_of_friend)

    expected_phone_numbers = [
      my_contacts.map(&:phone_number_id),
      friend.user_contacts.map(&:phone_number_id),
      friend_of_friend.user_contacts.map(&:phone_number_id),
    ].flatten
    result = PhoneNumber.find_by_sql(subject.call(user.id)).map(&:phone_number_id)
    expect(result).to(match_array(expected_phone_numbers))
  end
end
