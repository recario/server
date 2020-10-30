# frozen_string_literal: true
module Api
  module V1
    class FriendlyAdsController < ApplicationController
      before_action :require_auth

      def show
        ad = Ad.find(params[:id])
        friends = UserContact.ad_friends_for_user(ad, current_user).includes(phone_number: :user)
        chat_rooms = ChatRoom.joins(:chat_room_users).where(chat_room_users: { user: current_user }, ad: ad)

        payload = {
          friends: ActiveModel::SerializableResource.new(friends, each_serializer: Api::V1::AdFriendSerializer),
          chats: ActiveModel::SerializableResource.new(chat_rooms, each_serializer: Api::V1::ChatRoomSerializer),
        }

        render(json: payload)
      end
    end
  end
end
