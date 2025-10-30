require "test_helper"

# ===================================================================
# [4] UniqueWithinTimeWindowTest - Test Suite for Time Window Uniqueness
# ===================================================================
#
# Test Cases:
#  1. Unique Within Time Window - No overlap allowed
#  2. Unique Within Time Window - No overlap validation
#  3. Unique Within Time Window - With overlap
#  4. Unique Within Time Window - Open-ended (no starts_at)
#  5. Unique Within Time Window - Open-ended (no ends_at)
#  6. Different actions can overlap in time
#  7. Different resources can overlap in time
#  8. Different scopes can overlap in time
#  9. Different holders can have same permissions
# 10. Update should not conflict with self
#
# ===================================================================

class TheRole2::Concerns::UniqueWithinTimeWindowTest < ActiveSupport::TestCase
  setup do
    @user_john = users(:john)
    TheRole2::PermissionLog.actor = @user_john
  end

  teardown do
    TheRole2::PermissionLog.actor = nil
  end

  # Test Case 1: Permissions without time window overlap are allowed
  test "should allow permissions without time window overlap" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 30.minutes.ago
    )

    # This should be valid - no overlap
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 20.minutes.ago,
      ends_at: 10.minutes.ago
    )

    assert permission.valid?
  end

  # Test Case 2: Adjacent time windows should be allowed
  test "should allow adjacent time windows" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 30.minutes.ago
    )

    # End exactly when other starts - should be valid
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 30.minutes.ago,
      ends_at: 1.hour.from_now
    )

    assert permission.valid?
  end

  # Test Case 3: Overlapping time windows are rejected
  test "should reject permissions with time window overlap" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 30.minutes.ago
    )

    # This should be invalid - overlaps with first
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 40.minutes.ago,
      ends_at: 40.minutes.from_now
    )

    assert_not permission.valid?
    assert_includes permission.errors[:base].join, "overlapping time window"
  end

  # Test Case 4: Open-ended permissions (no starts_at)
  test "should handle permissions with no start time" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: nil,
      ends_at: 1.hour.from_now
    )

    # This should be invalid - overlaps (open start means from beginning)
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 2.hours.ago,
      ends_at: 30.minutes.from_now
    )

    assert_not permission.valid?
  end

  # Test Case 5: Open-ended permissions (no ends_at)
  test "should handle permissions with no end time" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: nil
    )

    # This should be invalid - overlaps (open end means to infinity)
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 30.minutes.from_now,
      ends_at: 2.hours.from_now
    )

    assert_not permission.valid?
  end

  # Test Case 6: Different actions can overlap in time
  test "should allow different actions to overlap in time" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    # Different action - should be valid
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "destroy",
      value: true,
      starts_at: 30.minutes.ago,
      ends_at: 30.minutes.from_now
    )

    assert permission.valid?
  end

  # Test Case 7: Different resources can overlap in time
  test "should allow different resources to overlap in time" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    # Different resource - should be valid
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "comments",
      action: "create",
      value: true,
      starts_at: 30.minutes.ago,
      ends_at: 30.minutes.from_now
    )

    assert permission.valid?
  end

  # Test Case 8: Different scopes can overlap in time
  test "should allow different scopes to overlap in time" do
    @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    # Different scope - should be valid
    permission = @user_john.permissions.create(
      scope: "school",
      resource: "exams",
      action: "create",
      value: true,
      starts_at: 30.minutes.ago,
      ends_at: 30.minutes.from_now
    )

    assert permission.valid?
  end

  # Test Case 9: Different holders can have same permissions
  test "should allow different holders to have same permissions" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    user_alice = users(:alice)
    TheRole2::PermissionLog.actor = user_alice

    # Different holder - should be valid
    permission = user_alice.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 30.minutes.ago,
      ends_at: 30.minutes.from_now
    )

    assert permission.valid?
  end

  # Test Case 10: Updating permission should not conflict with itself
  test "should allow updating permission without conflict" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    # Update should not fail
    permission.update!(enabled: false)
    assert permission.valid?
  end

  # Test Case 11: Full overlap is rejected
  test "should reject fully overlapping permissions" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 2.hours.ago,
      ends_at: 2.hours.from_now
    )

    # Identical time window - should be invalid
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 2.hours.ago,
      ends_at: 2.hours.from_now
    )

    assert_not permission.valid?
  end

  # Test Case 12: Partial overlap is rejected
  test "should reject partially overlapping permissions" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    # Overlaps on the right side - should be invalid
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: 30.minutes.from_now,
      ends_at: 3.hours.from_now
    )

    assert_not permission.valid?
  end

  # Test Case 13: Permissions with both nil times
  test "should reject when both permissions have no time limits" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: nil,
      ends_at: nil
    )

    # Both open-ended - should be invalid
    permission = @user_john.permissions.create(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      starts_at: nil,
      ends_at: nil
    )

    assert_not permission.valid?
  end
end
