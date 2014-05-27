# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140510121848) do

  create_table "categories", :force => true do |t|
    t.string   "name",        :null => false
    t.integer  "position",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "category_id"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "forums", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "image",      :null => false
    t.string   "root",       :null => false
    t.string   "tail"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "forums", ["name"], :name => "index_forums_on_name", :unique => true

  create_table "link_urls", :force => true do |t|
    t.string   "link",                               :null => false
    t.string   "title",                              :null => false
    t.boolean  "current",         :default => false
    t.integer  "product_link_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "link_urls", ["link"], :name => "index_link_urls_on_link", :unique => true

  create_table "product_links", :force => true do |t|
    t.boolean  "active",     :default => false
    t.integer  "forum_id",                      :null => false
    t.integer  "product_id",                    :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name",        :null => false
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "products", ["name"], :name => "index_products_on_name", :unique => true

  create_table "reports", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.date     "report_date"
  end

  create_table "review_froms", :force => true do |t|
    t.string   "phrase",     :null => false
    t.integer  "product_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "review_froms", ["phrase"], :name => "index_review_froms_on_phrase", :unique => true

  create_table "reviews", :force => true do |t|
    t.string   "type"
    t.date     "review_date",                       :null => false
    t.string   "author",                            :null => false
    t.string   "location"
    t.integer  "rating",                            :null => false
    t.string   "headline",       :default => ""
    t.text     "body",           :default => ""
    t.string   "unique_key",                        :null => false
    t.integer  "link_url_id",                       :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "exclude",        :default => false
    t.integer  "review_from_id"
    t.integer  "product_id"
  end

  add_index "reviews", ["unique_key"], :name => "index_reviews_on_unique_key", :unique => true

end
