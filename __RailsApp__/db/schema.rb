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

ActiveRecord::Schema[8.1].define(version: 2025_10_26_000001) do
  create_table "the_role2_permission_logs", force: :cascade do |t|
    t.string "action", null: false
    t.integer "actor_id", null: false
    t.string "actor_type", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.integer "permission_id", null: false
    t.json "snapshot", default: {}
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_the_role2_permission_logs_on_actor"
    t.index ["permission_id"], name: "index_the_role2_permission_logs_on_permission_id"
  end

  create_table "the_role2_permissions", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "enabled", default: true, null: false
    t.datetime "ends_at"
    t.integer "holder_id", null: false
    t.string "holder_type", null: false
    t.string "resource", null: false
    t.string "scope"
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.boolean "value", default: true, null: false
    t.index ["holder_type", "holder_id", "scope", "resource", "action"], name: "idx_the_role2_permissions_holder_scope_resource_action", unique: true
    t.index ["holder_type", "holder_id"], name: "index_the_role2_permissions_on_holder"
  end

  add_foreign_key "the_role2_permission_logs", "the_role2_permissions", column: "permission_id"
end
