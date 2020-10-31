# frozen_string_literal: true
class InitiateChatRoom
  def call(ad_id:, initiator_user_id:, user_id:)
    ad = Ad.find(ad_id)
    initiator = User.find(initiator_user_id)
    user = User.find(user_id)

    raise unless initiator.user_contacts.exists?(phone_number: user.phone_number)

    ChatRoom.transaction do
      chat_room = initiator.chat_rooms.create!(ad: ad)
      chat_room.chat_room_users.create!(user: initiator)
      chat_room.chat_room_users.create!(user: user)
      chat_room.messages.create!(system: true, body: "#{initiator.name || 'Безымянный'} поинтересовался объявлением")
      initiator_payload = Api::V1::ChatRoomSerializer.new(chat_room, current_user_id: initiator.id).as_json
      user_payload = Api::V1::ChatRoomSerializer.new(chat_room, current_user_id: user.id).as_json
      ApplicationCable::UserChannel.broadcast_to(initiator, type: 'initiate_chat', chat: initiator_payload)
      ApplicationCable::UserChannel.broadcast_to(user, type: 'chat', chat: user_payload)
    end
  end
end