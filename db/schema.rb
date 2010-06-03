# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2) do

  create_table "medias", :force => true do |t|
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "media_file_name"
    t.string  "media_content_type"
    t.string  "media_file_size"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.string  "etag"
    t.string  "full_filename"
  end

  create_table "messages", :force => true do |t|
    t.text     "body"
    t.datetime "received_date"
    t.string   "type"
  end

end
