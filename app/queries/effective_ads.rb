# frozen_string_literal: true
class EffectiveAds
  def call(filters:, should_search_query:)
    ads = Ad.from('effective_ads AS ads')
    ads = ads.select('DISTINCT ON (ads.id) ads.id, ads.phone_number_id, ads.created_at')
    ads = ads.where('price >= ?', filters[:min_price]) if filters[:min_price].present?
    ads = ads.where('price <= ?', filters[:max_price]) if filters[:max_price].present?

    ads = ads.where("details->>'year' >= ?", filters[:min_year]) if filters[:min_year].present?
    ads = ads.where("details->>'year' <= ?", filters[:max_year]) if filters[:max_year].present?

    ads = ads.where("details->>'fuel' IN (?)", filters[:fuels]) if filters[:fuels].present?
    ads = ads.where("details->>'gear' IN (?)", filters[:gears]) if filters[:gears].present?
    ads = ads.where("details->>'wheels' IN (?)", filters[:wheels]) if filters[:wheels].present?
    ads = ads.where("details->>'carcass' IN (?)", filters[:carcasses]) if filters[:carcasses].present?

    if filters[:query].present? && should_search_query
      # TODO: Add search by year
      ads = ads.where("CONCAT(details->>'maker', ' ',details->>'model') ILIKE :q OR details->>'model' ILIKE :q", q: "#{filters[:query].strip}%")
    end

    ads.to_sql
  end
end