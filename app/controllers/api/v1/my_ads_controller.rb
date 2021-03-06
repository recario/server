# frozen_string_literal: true
module Api
  module V1
    class MyAdsController < ApplicationController
      before_action :require_auth

      def index
        ads = current_user.ads.order(created_at: :desc).limit(20).offset(params[:offset])

        render(json: ads, each_serializer: Api::V1::AdsListSerializer)
      end
    end
  end
end
