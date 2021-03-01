# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(UserFriendlyAdsQuery) do
  let!(:some_phone_number) { create(:phone_number) }
  let!(:user) { create(:user) }
  let!(:friend) { create(:user) }
  let!(:friend_of_friend) { create(:user) }
  let!(:hand1_of_friend_of_friend) { create(:user) }

  let!(:ad_hand1_no_user) { create(:ad, :active, phone: some_phone_number.full_number) }
  let!(:ad_hand1) { create(:ad, :active, phone: friend.phone_number) }
  let!(:ad_hand2) { create(:ad, :active, phone: friend_of_friend.phone_number) }
  let!(:ad_hand3) { create(:ad, :active, phone: hand1_of_friend_of_friend.phone_number) }
  let!(:ad_unknown) { create(:ad, :active) }

  before do
    create(:user_contact, user: user, phone_number: some_phone_number)
    create(:user_contact, user: user, phone_number: friend.phone_number)
    create(:user_contact, user: friend, phone_number: friend_of_friend.phone_number)
    create(:user_contact, user: friend_of_friend, phone_number: hand1_of_friend_of_friend.phone_number)
  end

  context 'With successful result' do
    subject { described_class.new.call(user: user) }
    it 'matches expected friendly ads' do
      expected_ads = [
        ad_hand1, ad_hand2, ad_hand3, ad_hand1_no_user
      ]
      is_expected.to(match_array(expected_ads))
    end

    it 'returns Ad relation' do
      is_expected.to(be_a(ActiveRecord::Relation))
    end

    it 'does not show deleted ads' do
      ad_hand2.update(deleted: true)
      expected_ads = [
        ad_hand1, ad_hand3, ad_hand1_no_user
      ]
      is_expected.to(match_array(expected_ads))
    end

    it 'applies offset' do
      expect(described_class.new.call(user: user, offset: 2).count).to(eq(2))
    end

    it 'orders by date' do
      expect(subject.last.id).to(eq(ad_hand1_no_user.id))
      expect(subject.first.id).to(eq(ad_hand3.id))
      expect(subject.first.created_at).to(be > subject.last.created_at)
    end

    it 'limits result' do
      UserFriendlyAdsQuery::LIMIT.times do
        create(:user_contact, user: user, phone_number: create(:ad, :active).phone_number)
      end

      expect(described_class.new.call(user: user).count).to(eq(UserFriendlyAdsQuery::LIMIT))
    end

    it 'filters by maker and model if not match user contacts' do
      ad = create(:ad, :active, phone: friend.phone_number)
      ad.details['maker'] = 'BMW'
      ad.details['model'] = 'X6'
      ad.save

      expect(described_class.new.call(user: user, filters: { query: 'BMW X6' })).to(match_array([ad]))
      expect(described_class.new.call(user: user, filters: { query: 'BMW' })).to(match_array([ad]))
      expect(described_class.new.call(user: user, filters: { query: 'X6' })).to(match_array([ad]))
    end

    # TODO: May occasionally fail
    it 'filters by user contacts if match hand1' do
      new_friend = create(:user)
      create(:user_contact, user: user, phone_number: new_friend.phone_number, name: 'John')
      ad = create(:ad, :active, phone: new_friend.phone_number)
      expected_ads = described_class.new.call(user: user, filters: { query: 'John' })
      expect(expected_ads).to(match_array([ad]))
    end

    it 'filters by user contacts if match hand2 and hand3' do
      user.user_contacts.find_by(phone_number: friend.phone_number).update(name: 'John')
      expected_ads = described_class.new.call(user: user, filters: { query: 'John' })
      expect(expected_ads).to(match_array([ad_hand1, ad_hand2, ad_hand3]))
    end

    it 'filters by contacts_mode' do
      expected_ads = [ad_hand1_no_user, ad_hand1]
      expect(described_class.new.call(user: user, filters: { contacts_mode: 'directFriends' })).to(match_array(expected_ads))
    end
  end
end
