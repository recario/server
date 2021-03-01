# frozen_string_literal: true
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_06_130842) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string("namespace")
    t.text("body")
    t.string("resource_type")
    t.bigint("resource_id")
    t.string("author_type")
    t.bigint("author_id")
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.index(["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id")
    t.index(["namespace"], name: "index_active_admin_comments_on_namespace")
    t.index(["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id")
  end

  create_table "ad_favorites", force: :cascade do |t|
    t.bigint("ad_id", null: false)
    t.bigint("user_id", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.index(["ad_id", "user_id"], name: "index_ad_favorites_on_ad_id_and_user_id", unique: true)
    t.index(["user_id"], name: "index_ad_favorites_on_user_id")
  end

  create_table "ad_visits", force: :cascade do |t|
    t.bigint("user_id", null: false)
    t.bigint("ad_id", null: false)
    t.index(["ad_id", "user_id"], name: "index_ad_visits_on_ad_id_and_user_id", unique: true)
    t.index(["user_id"], name: "index_ad_visits_on_user_id")
  end

  create_table "admin_users", force: :cascade do |t|
    t.string("email", default: "", null: false)
    t.string("encrypted_password", default: "", null: false)
    t.string("reset_password_token")
    t.datetime("reset_password_sent_at")
    t.datetime("remember_created_at")
    t.index(["email"], name: "index_admin_users_on_email", unique: true)
    t.index(["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true)
  end

  create_table "ads", force: :cascade do |t|
    t.bigint("phone_number_id", null: false)
    t.bigint("ads_source_id", null: false)
    t.integer("price", null: false)
    t.boolean("deleted", default: false, null: false)
    t.jsonb("details", null: false)
    t.string("ad_type", null: false)
    t.string("address", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.index("(((details -> 'region'::text) ->> 0)), ((details ->> 'year'::text)), ((details ->> 'maker'::text)), ((details ->> 'model'::text))", name: "details_region_year_maker_model_index")
    t.index("((details ->> 'carcass'::text))", name: "index_ads_on_details_carcass")
    t.index("((details ->> 'fuel'::text))", name: "index_ads_on_details_fuel")
    t.index("((details ->> 'gear'::text))", name: "index_ads_on_details_gear")
    t.index("((details ->> 'maker'::text))", name: "index_ads_on_details_maker", using: :gist)
    t.index("((details ->> 'model'::text))", name: "index_ads_on_details_model", using: :gist)
    t.index("((details ->> 'wheels'::text))", name: "index_ads_on_details_wheels")
    t.index("((details ->> 'year'::text))", name: "index_ads_on_details_year")
    t.index(["address", "ads_source_id"], name: "index_ads_on_address_and_ads_source_id", unique: true)
    t.index(["phone_number_id", "created_at"], name: "index_ads_on_phone_number_id_and_created_at", order: { created_at: :desc }, where: "(deleted = false)")
    t.index(["phone_number_id"], name: "index_ads_on_phone_number_id")
    t.index(["price"], name: "index_ads_on_price")
  end

  create_table "ads_sources", force: :cascade do |t|
    t.string("title", null: false)
    t.string("api_token", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.index(["api_token"], name: "index_ads_sources_on_api_token", unique: true)
    t.index(["title"], name: "index_ads_sources_on_title", unique: true)
  end

  create_table "chat_room_users", force: :cascade do |t|
    t.bigint("chat_room_id", null: false)
    t.bigint("user_id", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.string("name", null: false)
    t.index(["chat_room_id", "user_id"], name: "index_chat_room_users_on_chat_room_id_and_user_id", unique: true)
    t.index(["chat_room_id"], name: "index_chat_room_users_on_chat_room_id")
    t.index(["user_id"], name: "index_chat_room_users_on_user_id")
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.bigint("user_id", null: false)
    t.bigint("ad_id", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.boolean("system", default: false, null: false)
    t.index(["ad_id"], name: "index_chat_rooms_on_ad_id")
    t.index(["user_id"], name: "index_chat_rooms_on_user_id")
    t.index(["user_id"], name: "index_on_chat_rooms_user_id_where_system_true", unique: true, where: "(system = true)")
  end

  create_table "demo_phone_numbers", force: :cascade do |t|
    t.bigint("phone_number_id", null: false)
    t.integer("demo_code")
    t.index(["phone_number_id"], name: "index_demo_phone_numbers_on_phone_number_id")
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string("body", null: false)
    t.boolean("system", default: false, null: false)
    t.bigint("user_id")
    t.bigint("chat_room_id", null: false)
    t.datetime("created_at", null: false)
    t.index(["chat_room_id"], name: "index_messages_on_chat_room_id")
    t.index(["user_id"], name: "index_messages_on_user_id")
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.string("full_number", limit: 9, null: false)
    t.index(["full_number"], name: "index_phone_numbers_on_full_number", unique: true)
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string("name", null: false)
    t.string("environment")
    t.text("certificate")
    t.string("password")
    t.integer("connections", default: 1, null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.string("type", null: false)
    t.string("auth_key")
    t.string("client_id")
    t.string("client_secret")
    t.string("access_token")
    t.datetime("access_token_expiration")
    t.text("apn_key")
    t.string("apn_key_id")
    t.string("team_id")
    t.string("bundle_id")
    t.boolean("feedback_enabled", default: true)
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string("device_token")
    t.datetime("failed_at", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.integer("app_id")
    t.index(["device_token"], name: "index_rpush_feedback_on_device_token")
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer("badge")
    t.string("device_token")
    t.string("sound")
    t.text("alert")
    t.text("data")
    t.integer("expiry", default: 86400)
    t.boolean("delivered", default: false, null: false)
    t.datetime("delivered_at")
    t.boolean("failed", default: false, null: false)
    t.datetime("failed_at")
    t.integer("error_code")
    t.text("error_description")
    t.datetime("deliver_after")
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.boolean("alert_is_json", default: false, null: false)
    t.string("type", null: false)
    t.string("collapse_key")
    t.boolean("delay_while_idle", default: false, null: false)
    t.text("registration_ids")
    t.integer("app_id", null: false)
    t.integer("retries", default: 0)
    t.string("uri")
    t.datetime("fail_after")
    t.boolean("processing", default: false, null: false)
    t.integer("priority")
    t.text("url_args")
    t.string("category")
    t.boolean("content_available", default: false, null: false)
    t.text("notification")
    t.boolean("mutable_content", default: false, null: false)
    t.string("external_device_id")
    t.string("thread_id")
    t.boolean("dry_run", default: false, null: false)
    t.boolean("sound_is_json", default: false)
    t.index(["delivered", "failed", "processing", "deliver_after", "created_at"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))")
  end

  create_table "static_pages", force: :cascade do |t|
    t.string("title", null: false)
    t.string("slug", null: false)
    t.text("body")
    t.jsonb("meta")
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.index(["slug"], name: "index_static_pages_on_slug", unique: true)
  end

  create_table "user_contacts", force: :cascade do |t|
    t.bigint("user_id", null: false)
    t.bigint("phone_number_id", null: false)
    t.string("name", limit: 100, null: false)
    t.index(["name"], name: "index_user_contacts_on_name", opclass: :gist_trgm_ops, using: :gist)
    t.index(["phone_number_id", "user_id"], name: "index_user_contacts_on_phone_number_id_and_user_id", unique: true)
    t.index(["user_id"], name: "index_user_contacts_on_user_id")
  end

  create_table "user_device_stats", force: :cascade do |t|
    t.integer("user_devices_appeared_count", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
  end

  create_table "user_devices", force: :cascade do |t|
    t.bigint("user_id", null: false)
    t.string("device_id", null: false)
    t.string("access_token", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.string("os")
    t.string("push_token")
    t.string("build_version")
    t.index(["access_token"], name: "index_user_devices_on_access_token", unique: true)
    t.index(["device_id"], name: "index_user_devices_on_device_id", unique: true)
    t.index(["user_id"], name: "index_user_devices_on_user_id")
  end

  create_table "users", force: :cascade do |t|
    t.bigint("phone_number_id", null: false)
    t.string("name")
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.json("avatar")
    t.index(["phone_number_id"], name: "index_users_on_phone_number_id", unique: true)
  end

  create_table "verification_requests", force: :cascade do |t|
    t.bigint("phone_number_id", null: false)
    t.integer("verification_code", null: false)
    t.datetime("created_at", precision: 6, null: false)
    t.datetime("updated_at", precision: 6, null: false)
    t.index(["phone_number_id"], name: "index_verification_requests_on_phone_number_id", unique: true)
  end

  create_table "versions", force: :cascade do |t|
    t.string("item_type")
    t.string("{:null=>false}")
    t.bigint("item_id", null: false)
    t.string("event", null: false)
    t.string("whodunnit")
    t.text("object")
    t.datetime("created_at")
    t.index(["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id")
  end

  add_foreign_key "ad_favorites", "ads", on_delete: :cascade
  add_foreign_key "ad_favorites", "users", on_delete: :cascade
  add_foreign_key "ad_visits", "ads", on_delete: :cascade
  add_foreign_key "ad_visits", "users", on_delete: :cascade
  add_foreign_key "ads", "ads_sources", on_delete: :cascade
  add_foreign_key "ads", "phone_numbers", on_delete: :cascade
  add_foreign_key "user_contacts", "phone_numbers", on_delete: :cascade
  add_foreign_key "user_contacts", "users", on_delete: :cascade
  add_foreign_key "user_devices", "users", on_delete: :cascade
  add_foreign_key "users", "phone_numbers", on_delete: :cascade
end
