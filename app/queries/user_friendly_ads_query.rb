# frozen_string_literal: true
class UserFriendlyAdsQuery
  LIMIT = 20

  def call(user:, offset: 0, limit: LIMIT, filters: {})
    user_contacts_matched_phone_numbers = user.user_contacts.where('user_contacts.name ILIKE ?', "%#{filters[:query]}%").pluck(:phone_number_id) if filters[:query].present?
    effective_ads = EffectiveAds.new.call(filters: filters, should_search_query: user_contacts_matched_phone_numbers.blank?)

    known_numbers = if filters[:contacts_mode] == 'directFriends'
      "SELECT phone_number_id FROM user_contacts WHERE user_id = #{user.id}"
    elsif user_contacts_matched_phone_numbers.present?
      KnownNumbersFiltered.new.call(user_phone_number_id: user.phone_number_id, friend_phone_number_ids: user_contacts_matched_phone_numbers)
    else
      KnownNumbers.new.call(user.id)
    end

    ads = Ad.from("(#{effective_ads}) AS ads").joins("JOIN (#{known_numbers}) AS known_numbers ON known_numbers.phone_number_id = ads.phone_number_id")

    query = ads.offset(offset).order(created_at: :desc)
    query = query.limit(limit) if limit > 0
    query
  end
end
