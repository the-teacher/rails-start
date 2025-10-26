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

ActiveRecord::Schema[8.1].define(version: 2025_10_26_000008) do
  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "current_role_id"
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["current_role_id"], name: "index_companies_on_current_role_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "bio"
    t.datetime "created_at", null: false
    t.bigint "current_role_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["current_role_id"], name: "index_profiles_on_current_role_id"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "current_role_id"
    t.string "grade"
    t.string "student_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["current_role_id"], name: "index_students_on_current_role_id"
    t.index ["student_id"], name: "index_students_on_student_id", unique: true
    t.index ["user_id"], name: "index_students_on_user_id"
  end

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

  create_table "the_role2_role_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "holder_id", null: false
    t.string "holder_type", null: false
    t.integer "the_role2_role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["holder_type", "holder_id"], name: "index_the_role2_role_assignments_on_holder"
    t.index ["the_role2_role_id", "holder_type", "holder_id"], name: "idx_the_role2_role_assignments_role_holder", unique: true
    t.index ["the_role2_role_id"], name: "index_the_role2_role_assignments_on_the_role2_role_id"
  end

  create_table "the_role2_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_the_role2_roles_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "current_role_id"
    t.string "email", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["current_role_id"], name: "index_users_on_current_role_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "companies", "the_role2_roles", column: "current_role_id"
  add_foreign_key "companies", "the_role2_roles", column: "current_role_id"
  add_foreign_key "profiles", "the_role2_roles", column: "current_role_id"
  add_foreign_key "profiles", "the_role2_roles", column: "current_role_id"
  add_foreign_key "profiles", "users"
  add_foreign_key "students", "the_role2_roles", column: "current_role_id"
  add_foreign_key "students", "the_role2_roles", column: "current_role_id"
  add_foreign_key "students", "users"
  add_foreign_key "the_role2_permission_logs", "the_role2_permissions", column: "permission_id"
  add_foreign_key "the_role2_role_assignments", "the_role2_roles"
  add_foreign_key "users", "the_role2_roles", column: "current_role_id"
  add_foreign_key "users", "the_role2_roles", column: "current_role_id"
end
