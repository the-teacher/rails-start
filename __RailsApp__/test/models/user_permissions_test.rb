require "test_helper"

# ===================================================================
# [1] User::PermissionsTest - Complete Test Suite for Permission System
# ===================================================================
#
# Test Cases:
#  1. Permission Creation - Create permission directly on user model
#  2. Permission Lookup - Check permission using has_permission? method
#  3. Missing Permission - Verify missing permission returns false
#  4. Scoped Permissions - Check permissions with scope (university, department, etc.)
#  5. Disable Permission - Verify permission can be disabled
#  6. Enable Permission - Verify permission can be enabled
#  7. Multiple Permissions - Check multiple permissions at once
#  8. Specific Permission Check - Verify specific permission check
#  9. Disabled Permissions Cache - Verify disabled permissions are cached correctly
# 10. Full Key Format - Verify full key generation without scope
# 11. Full Key With Scope - Verify full key generation with scope
# 12. Title Alias - Verify title is an alias for full_key
# 13. Permission Effectiveness - Check if permission is effective when enabled
# 14. Disabled Effectiveness - Verify disabled permission is not effective
# 15. Time Window Effectiveness - Check effectiveness within time window
# 16. Before Start Time - Verify permission is not effective before starts_at
# 17. After End Time - Verify permission is not effective after ends_at
# 18. Enable Permission - Test enable! method
# 19. Disable Permission - Test disable! method
# 20. Grant Permission On - Test on! method to grant permission
# 21. Deny Permission Off - Test off! method to deny permission
# 22. Parse Key Full - Parse key with full format (scope::resource::action)
# 23. Parse Key Simple - Parse key with simple format (resource::action)
# 24. Parse Key Invalid - Parse invalid key format
# 25. Find By Key - Find permission by key using by_key scope
# 26. Find By Key With Scope - Find permission by key with scope
# 27. Enabled Scope Filter - Filter enabled permissions
# 28. Effective Scope Filter - Filter effective permissions (enabled and within time window)
# 29. Holder Validation - Permission requires a holder
# ===================================================================

class User::PermissionsTest < ActiveSupport::TestCase
  setup do
    @user_john = users(:john)
    # Set permission actor for audit trail
    TheRole2::PermissionLog.actor = @user_john
  end

  # Test Case 1: Permission can be created directly on user
  test "should create permissions directly on user" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    assert_equal 1, @user_john.permissions.count

    assert_nil @user_john.permissions.first.scope
    assert_equal "posts", @user_john.permissions.first.resource
    assert_equal "create", @user_john.permissions.first.action
  end

  # Test Case 2: Permission lookup with has_permission?
  test "should check permission using has_permission?" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    @user_john.preload_permissions!
    assert @user_john.has_permission?("posts::create")
  end

  # Test Case 3: Missing permission returns false
  test "should return false for missing permission" do
    @user_john.preload_permissions!
    assert_not @user_john.has_permission?("posts::destroy")
  end

  # Test Case 4: Scoped permissions (with scope like university)
  test "should check scoped permissions" do
    @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "show",
      value: true
    )

    @user_john.preload_permissions!
    assert @user_john.has_permission?("university::exams::show")
    assert_not @user_john.has_permission?("exams::show")
  end

  # Test Case 5: Disable permission using user method
  test "should disable permission" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )

    @user_john.disable_permission!("posts::create")
    permission.reload
    assert_not permission.enabled
  end

  # Test Case 6: Enable permission using user method
  test "should enable permission" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: false
    )

    @user_john.enable_permission!("posts::create")
    permission.reload
    assert permission.enabled
  end

  # Test Case 7: Check multiple permissions at once
  test "should check multiple permissions" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "destroy",
      value: false
    )
    @user_john.permissions.create!(
      scope: nil,
      resource: "comments",
      action: "create",
      value: true
    )

    @user_john.preload_permissions!
    assert @user_john.has_permission?("posts::create")
    assert_not @user_john.has_permission?("posts::destroy")
    assert @user_john.has_permission?("comments::create")
  end

  # Test Case 8: Check specific permission without preload
  test "should check specific permission" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    assert @user_john.has_permission?("posts::create")
  end

  # Test Case 9: Disabled permissions are not available in cache
  test "should handle disabled permissions in cache" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: false
    )

    @user_john.preload_permissions!
    assert_not @user_john.has_permission?("posts::create")
  end

  # Test Case 10: Full key format without scope
  test "should return full_key for permission" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    assert_equal "posts::create", permission.full_key
  end

  # Test Case 11: Full key format with scope
  test "should return full_key with scope for permission" do
    permission = @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "show",
      value: true
    )

    assert_equal "university::exams::show", permission.full_key
  end

  # Test Case 12: Title is alias for full_key
  test "should return title as alias for full_key" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "destroy",
      value: false
    )

    assert_equal permission.full_key, permission.title
  end

  # Test Case 13: Permission is effective when enabled
  test "should check if permission is effective" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )

    assert permission.effective?
  end

  # Test Case 14: Disabled permission is not effective
  test "should return false if permission is disabled when checking effective" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: false
    )

    assert_not permission.effective?
  end

  # Test Case 15: Permission is effective within time window
  test "should check effective with time window" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    assert permission.effective?
  end

  # Test Case 16: Permission is not effective before starts_at time
  test "should return false if permission is before starts_at" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true,
      starts_at: 1.hour.from_now,
      ends_at: 2.hours.from_now
    )

    assert_not permission.effective?
  end

  # Test Case 17: Permission is not effective after ends_at time
  test "should return false if permission is after ends_at" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true,
      starts_at: 2.hours.ago,
      ends_at: 1.hour.ago
    )

    assert_not permission.effective?
  end

  # Test Case 18: Enable permission using enable! method
  test "should enable permission using enable!" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: false
    )

    permission.enable!
    assert permission.reload.enabled
  end

  # Test Case 19: Disable permission using disable! method
  test "should disable permission using disable!" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )

    permission.disable!
    assert_not permission.reload.enabled
  end

  # Test Case 20: Grant permission using on! method
  test "should grant permission using on!" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: false
    )

    permission.on!
    assert permission.reload.value
  end

  # Test Case 21: Deny permission using off! method
  test "should deny permission using off!" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    permission.off!
    assert_not permission.reload.value
  end

  # Test Case 22: Parse key with full format (scope::resource::action)
  test "should parse key with all three components" do
    scope, resource, action = TheRole2::Permission.parse_key("university::exams::show")

    assert_equal "university", scope
    assert_equal "exams", resource
    assert_equal "show", action
  end

  # Test Case 23: Parse key with simple format (resource::action)
  test "should parse key with resource and action only" do
    scope, resource, action = TheRole2::Permission.parse_key("posts::create")

    assert_nil scope
    assert_equal "posts", resource
    assert_equal "create", action
  end

  # Test Case 24: Parse key with invalid format
  test "should parse key with invalid format" do
    scope, resource, action = TheRole2::Permission.parse_key("invalid")

    assert_nil scope
    assert_nil resource
    assert_nil action
  end

  # Test Case 25: Find permission by key using by_key scope
  test "should find permission by key using by_key scope" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    found = @user_john.permissions.by_key("posts::create")
    assert_includes found, permission
  end

  # Test Case 26: Find permission by key with scope
  test "should find permission by key with scope using by_key scope" do
    permission = @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "show",
      value: true
    )

    found = @user_john.permissions.by_key("university::exams::show")
    assert_includes found, permission
  end

  # Test Case 27: Filter enabled permissions
  test "should filter enabled permissions" do
    enabled_permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )

    disabled_permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "destroy",
      value: true,
      enabled: false
    )

    enabled_perms = @user_john.permissions.enabled
    assert_includes enabled_perms, enabled_permission
    assert_not_includes enabled_perms, disabled_permission
  end

  # Test Case 28: Filter effective permissions (enabled and within time window)
  test "should filter effective permissions" do
    effective_permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true,
      starts_at: 1.hour.ago,
      ends_at: 1.hour.from_now
    )

    expired_permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "destroy",
      value: true,
      enabled: true,
      starts_at: 2.hours.ago,
      ends_at: 1.hour.ago
    )

    effective_perms = @user_john.permissions.effective
    assert_includes effective_perms, effective_permission
    assert_not_includes effective_perms, expired_permission
  end

  # Test Case 29: Holder Validation - Permission requires a holder
  test "should require holder for permission" do
    permission = TheRole2::Permission.new(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    assert_not permission.valid?
    assert_includes permission.errors[:holder], "can't be blank"
  end
end
