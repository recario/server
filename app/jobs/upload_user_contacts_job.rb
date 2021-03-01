# frozen_string_literal: true

class UploadUserContactsJob < ApplicationJob
  queue_as :contacts

  def perform(user_id, contacts)
    user = User.find(user_id)
    contacts = JSON.parse(contacts)
    initial_contacts_count = user.user_contacts.count
    User.transaction do
      contacts.each do |contact|
        contact['phoneNumbers'].each do |phone|
          number = Phonelib.parse(phone)
          next if number.invalid?

          phone_number = PhoneNumber.by_full_number(phone).first_or_create
          next if !phone_number.valid? || !phone_number.persisted?

          user_contact = user.user_contacts.where(phone_number: phone_number).first_or_initialize
          user_contact.name = contact['name'].to_s.strip.gsub(/^(.{97,}?).*$/m, '\1...')
          user_contact.save
        end
      end
      EffectiveAdsRefreshMaterializedView.perform_later
      ApplicationCable::UserChannel.broadcast_to(user, type: 'contacts') if initial_contacts_count.zero?
    end
  end
end
