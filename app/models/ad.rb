# frozen_string_literal: true

class Ad < ApplicationRecord
  AD_TYPES = %w[car real_estate].freeze

  attr_reader :friend_name_and_total

  has_paper_trail

  validates :price, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :address, uniqueness: { scope: :ads_source_id }
  validates :ad_type, inclusion: { in: AD_TYPES }
  validates :details, presence: true, json: true
  validates :deleted, inclusion: { in: [true, false] }

  validate :details_object

  belongs_to :ads_source
  belongs_to :phone_number
  has_many :ad_visits, dependent: :delete_all
  has_many :ad_favorites, dependent: :delete_all

  scope :active, -> { where(deleted: false) }

  def phone=(val)
    self.phone_number = PhoneNumber.by_full_number(val).first_or_create! if val.present?
  end

  def associate_friends_with(ads_with_friends)
    associated = ads_with_friends.select { |ad_with_friends| ad_with_friends.id == id }
    return if associated.blank?

    friend = associated.detect(&:is_first_hand) || associated.first

    # TODO: Fix N+1 query
    associated.reject! { |f| !f.is_first_hand && UserContact.exists?(id: f.friend_id, phone_number_id: phone_number_id) }

    @friend_name_and_total = {
      name: friend.friend_name,
      friend_hands: friend.is_first_hand ? 1 : 2,
      count: (associated.count - 1),
    }
  end

  private

  def details_object
    parsed_json = details.is_a?(String) ? JSON.parse(details) : details
    errors.add(:details, 'must be a Hash') unless parsed_json.is_a?(Hash)
  rescue JSON::ParserError
    errors.add(:details, 'is invalid')
  end
end
