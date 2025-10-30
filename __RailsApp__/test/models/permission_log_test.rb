require "test_helper"

# ===================================================================
# [3] PermissionLogTest - Test Suite for Permission Audit Logging
# ===================================================================
#
# Test Cases:
#  1. Log On Create - Create permission log when permission is created
#  2. Log On Update - Create permission log when permission is updated
#  3. Log On Delete - Create permission log when permission is deleted
#  4. Log Captures Snapshot - Log captures permission state at time of change
#  5. Log Records Actor - Log records who made the change
#  6. Log Records Action - Log correctly identifies the action (create/update/delete)
#  7. Multiple Logs Sequence - Verify logs track multiple changes in sequence
#  8. Log Snapshot Content - Verify snapshot contains all relevant fields
#  9. Log Without Actor Raises - Creating permission without actor should fail
# 10. Log Actor Polymorphic - Log actor works with different holder types
# 11. Log Delete Captures Final State - Delete log captures permission state before deletion
# 12. Log Created At Timestamp - Log records accurate creation timestamp
# 13. Log Update Preserves Creation - Multiple updates create separate logs
# 14. Permission Logs Association - Permission.logs returns all associated logs
# 15. Log Query By Action - Find logs by specific action type
#
# ===================================================================

class TheRole2::PermissionLogTest < ActiveSupport::TestCase
  setup do
    @user_john = users(:john)
    @user_alice = users(:alice)
  end

  teardown do
    # Clear thread-local actor after each test
    TheRole2::PermissionLog.actor = nil
  end

  # Test Case 1: Log is created when permission is created
  test "should create log on permission creation" do
    TheRole2::PermissionLog.actor = @user_john

    assert_difference "TheRole2::PermissionLog.count", 1 do
      @user_john.permissions.create!(
        scope: nil,
        resource: "posts",
        action: "create",
        value: true
      )
    end
  end

  # Test Case 2: Log is created when permission is updated
  test "should create log on permission update" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    initial_log_count = TheRole2::PermissionLog.count

    permission.update!(enabled: false)

    assert_equal initial_log_count + 1, TheRole2::PermissionLog.count
  end

  # Test Case 3: Log is created when permission is deleted
  test "should create log on permission deletion" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    initial_log_count = TheRole2::PermissionLog.count

    permission.destroy

    assert_equal initial_log_count + 1, TheRole2::PermissionLog.count
  end

  # Test Case 4: Log captures permission snapshot
  test "should capture snapshot in log" do
    TheRole2::PermissionLog.actor = @user_john
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true,
      description: "Can create posts"
    )

    log = TheRole2::PermissionLog.last
    assert_not_nil log
    snapshot = log.snapshot

    assert_equal "posts", snapshot["resource"]
    assert_equal "create", snapshot["action"]
    assert_equal true, snapshot["value"]
    assert_equal true, snapshot["enabled"]
    assert_equal "Can create posts", snapshot["description"]
  end

  # Test Case 5: Log records the actor
  test "should record actor in log" do
    TheRole2::PermissionLog.actor = @user_john
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    log = TheRole2::PermissionLog.last
    assert_not_nil log

    assert_equal @user_john.id, log.actor_id
    assert_equal @user_john.class.name, log.actor_type
    assert_equal @user_john, log.actor
  end

  # Test Case 6: Log records the action type
  test "should record action type in log" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    create_log = TheRole2::PermissionLog.last
    assert_equal "create", create_log.action

    permission.update!(enabled: false)
    update_log = TheRole2::PermissionLog.last
    assert_equal "update", update_log.action

    permission.destroy
    delete_log = TheRole2::PermissionLog.last
    assert_equal "delete", delete_log.action
  end

  # Test Case 7: Multiple logs track sequence of changes
  test "should track sequence of permission changes" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    permission.update!(enabled: false)
    permission.update!(description: "Updated")
    permission.destroy

    logs = permission.logs.order(:created_at)
    assert_equal 4, logs.count
    assert_equal "create", logs[0].action
    assert_equal "update", logs[1].action
    assert_equal "update", logs[2].action
    assert_equal "delete", logs[3].action
  end

  # Test Case 8: Log snapshot contains all permission fields
  test "should capture all fields in snapshot" do
    TheRole2::PermissionLog.actor = @user_john
    @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "show",
      value: false,
      enabled: true,
      description: "Show exams",
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    log = TheRole2::PermissionLog.last
    snapshot = log.snapshot

    assert_equal "university", snapshot["scope"]
    assert_equal "exams", snapshot["resource"]
    assert_equal "show", snapshot["action"]
    assert_equal false, snapshot["value"]
    assert_equal true, snapshot["enabled"]
    assert_equal "Show exams", snapshot["description"]
    assert_present snapshot["starts_at"]
    assert_present snapshot["ends_at"]
  end

  # Test Case 9: Creating permission without actor raises error
  test "should raise error if actor not set" do
    TheRole2::PermissionLog.actor = nil

    assert_raises RuntimeError do
      @user_john.permissions.create!(
        scope: nil,
        resource: "posts",
        action: "create",
        value: true
      )
    end
  end

  # Test Case 10: Log works with different polymorphic actors
  test "should log with different actor types" do
    TheRole2::PermissionLog.actor = @user_alice

    @user_alice.permissions.create!(
      scope: nil,
      resource: "reports",
      action: "view",
      value: true
    )

    log = TheRole2::PermissionLog.last
    assert_not_nil log
    assert_equal @user_alice.id, log.actor_id
    assert_equal "User", log.actor_type
    assert_equal @user_alice, log.actor
  end

  # Test Case 11: Delete log captures final state before deletion
  test "should capture permission state in delete log" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: false,
      description: "Final state"
    )

    permission.destroy

    delete_log = TheRole2::PermissionLog.where(action: "delete").last
    assert_not_nil delete_log
    snapshot = delete_log.snapshot

    assert_equal "posts", snapshot["resource"]
    assert_equal false, snapshot["enabled"]
    assert_equal "Final state", snapshot["description"]
  end

  # Test Case 12: Log records accurate timestamp
  test "should record creation timestamp" do
    TheRole2::PermissionLog.actor = @user_john
    before_time = Time.current
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )
    after_time = Time.current

    log = TheRole2::PermissionLog.last
    assert log.created_at >= before_time
    assert log.created_at <= after_time
  end

  # Test Case 13: Multiple updates create separate logs
  test "should create separate logs for each update" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    initial_log_count = TheRole2::PermissionLog.count

    permission.update!(enabled: false)
    permission.update!(description: "Updated 1")
    permission.update!(description: "Updated 2")

    assert_equal initial_log_count + 3, TheRole2::PermissionLog.count

    logs = permission.logs.where(action: "update").order(:created_at)
    assert_equal 3, logs.count
  end

  # Test Case 14: Permission.logs returns all associated logs
  test "should return all associated logs via permission.logs" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    permission.update!(enabled: false)
    permission.update!(description: "Updated")

    logs = permission.logs

    assert_equal 3, logs.count
    assert_equal permission.id, logs.first.permission_id
  end

  # Test Case 15: Query logs by action type
  test "should query logs by action type" do
    TheRole2::PermissionLog.actor = @user_john
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    permission.update!(enabled: false)
    permission.destroy

    create_logs = TheRole2::PermissionLog.where(action: "create")
    update_logs = TheRole2::PermissionLog.where(action: "update")
    delete_logs = TheRole2::PermissionLog.where(action: "delete")

    assert create_logs.any?
    assert_equal 1, update_logs.count
    assert_equal 1, delete_logs.count
  end

  # Test Case 16: Log snapshot is JSON
  test "should store snapshot as JSON" do
    TheRole2::PermissionLog.actor = @user_john
    @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "show",
      value: true
    )

    log = TheRole2::PermissionLog.last
    snapshot = log.snapshot

    assert_kind_of Hash, snapshot
    assert_respond_to snapshot, :[]
  end

  # Test Case 17: Actor relationship works bidirectionally
  test "should access logs through actor" do
    TheRole2::PermissionLog.actor = @user_john
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    @user_john.permissions.create!(
      scope: nil,
      resource: "comments",
      action: "create",
      value: true
    )

    # Through permissions.logs
    all_logs = @user_john.permissions.map(&:logs).flatten
    assert_equal 2, all_logs.count

    # All logs have correct actor
    all_logs.each do |log|
      assert_equal @user_john, log.actor
    end
  end

  # Test Case 18: Log enum action values
  test "should use enum for action field" do
    TheRole2::PermissionLog.actor = @user_john
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    log = TheRole2::PermissionLog.last

    # Test enum predicates
    assert log.action_create?
    assert_not log.action_update?
    assert_not log.action_delete?
  end
end
