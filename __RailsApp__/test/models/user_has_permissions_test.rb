require "test_helper"

# ===================================================================
# [2] User::HasPermissionsTest - Test Suite for HasPermissions Module
# ===================================================================
#
# Test Cases:
#  1. Preload Permissions - Load all effective permissions into cache
#  2. Preload Permissions Caching - Verify permissions are cached after preload
#  3. Permissions Hash - Get cached permissions with auto-load
#  4. Reload Permissions - Clear and reload permission cache
#  5. Has Permission With Cache - Check permission using cached permissions
#  6. Has Permission Without Cache - Check permission without cache
#  7. Has Permission Returns False - Permission check returns false when missing
#  8. Delete Permission - Delete a permission entirely
#  9. Delete Permission Clears Cache - Cache is cleared after deletion
# 10. Enable Permission - Re-enable a disabled permission
# 11. Enable Permission Updates Cache - Cache is updated when enabling
# 12. Disable Permission - Disable a permission without deleting
# 13. Disable Permission Clears Cache - Cache is cleared when disabling
# 14. Permission By Key Lookup - Find permission by compound key
# 15. Normalize Key - Normalize permission key format
# 16. Build Permission Key - Build compound key from components
#
# ===================================================================

class User::HasPermissionsTest < ActiveSupport::TestCase
  setup do
    @user_john = users(:john)
    # Set permission actor for audit trail
    TheRole2::PermissionLog.current_actor = @user_john
  end

  # Test Case 1: Preload permissions into cache
  test "should preload permissions into cache" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    @user_john.preload_permissions!
    assert @user_john.instance_variable_get(:@_permission_cache).present?
  end

  # Test Case 2: Preload caches only effective permissions
  test "should preload only effective permissions" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "destroy",
      value: true,
      enabled: false
    )

    @user_john.preload_permissions!
    cache = @user_john.instance_variable_get(:@_permission_cache)

    assert_includes cache, "posts::create"
    assert_not_includes cache, "posts::destroy"
  end

  # Test Case 3: Permissions hash auto-loads if not cached
  test "should auto-load permissions in permissions_hash" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    hash = @user_john.permissions_hash
    assert_includes hash, "posts::create"
  end

  # Test Case 4: Reload permissions clears and reloads cache
  test "should reload permissions cache" do
    permission = @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )

    @user_john.preload_permissions!

    permission.update!(enabled: false)
    @user_john.reload_permissions!

    reloaded_cache = @user_john.instance_variable_get(:@_permission_cache)
    assert_not_includes reloaded_cache, "posts::create"
  end

  # Test Case 5: Has permission checks cached permissions
  test "should check permission using cache" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    @user_john.preload_permissions!
    assert @user_john.has_permission?("posts::create")
  end

  # Test Case 6: Has permission works without cache via database
  test "should check permission without cache" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    assert @user_john.has_permission?("posts::create")
  end

  # Test Case 7: Has permission returns false when missing
  test "should return false for non-existent permission" do
    @user_john.preload_permissions!
    assert_not @user_john.has_permission?("posts::destroy")
  end

  # Test Case 8: Delete permission removes it entirely
  test "should delete permission" do
    TheRole2::PermissionLog.current_actor = @user_john
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    assert_equal 1, @user_john.permissions.count

    @user_john.delete_permission!("posts::create")
    assert_equal 0, @user_john.permissions.count
  end

  # Test Case 9: Delete permission clears cache
  test "should clear cache after deletion" do
    TheRole2::PermissionLog.current_actor = @user_john
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true
    )

    @user_john.preload_permissions!
    cache_before = @user_john.instance_variable_get(:@_permission_cache).dup

    @user_john.delete_permission!("posts::create")
    cache_after = @user_john.instance_variable_get(:@_permission_cache)

    assert_includes cache_before, "posts::create"
    assert_not_includes cache_after, "posts::create"
  end

  # Test Case 10: Enable permission re-enables disabled permission
  test "should enable a disabled permission" do
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

  # Test Case 11: Enable permission updates cache
  test "should update cache after enabling" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: false
    )

    @user_john.preload_permissions!
    cache_before = @user_john.instance_variable_get(:@_permission_cache).dup

    @user_john.enable_permission!("posts::create")
    cache_after = @user_john.instance_variable_get(:@_permission_cache)

    assert_not_includes cache_before, "posts::create"
    assert_includes cache_after, "posts::create"
  end

  # Test Case 12: Disable permission keeps it but doesn't apply
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
    assert_equal 1, @user_john.permissions.count
  end

  # Test Case 13: Disable permission removes from cache
  test "should remove permission from cache after disabling" do
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )

    @user_john.preload_permissions!
    cache_before = @user_john.instance_variable_get(:@_permission_cache).dup

    @user_john.disable_permission!("posts::create")
    cache_after = @user_john.instance_variable_get(:@_permission_cache)

    assert_includes cache_before, "posts::create"
    assert_not_includes cache_after, "posts::create"
  end

  # Test Case 14: Delete permission by scoped key
  test "should delete permission by scoped key" do
    TheRole2::PermissionLog.current_actor = @user_john
    @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "show",
      value: true
    )

    assert_equal 1, @user_john.permissions.count

    @user_john.delete_permission!("university::exams::show")
    assert_equal 0, @user_john.permissions.count
  end

  # Test Case 15: Has permission with scoped key
  test "should check scoped permission" do
    @user_john.permissions.create!(
      scope: "university",
      resource: "exams",
      action: "show",
      value: true
    )

    @user_john.preload_permissions!
    assert @user_john.has_permission?("university::exams::show")
  end

  # Test Case 16: Multiple operations sequence
  test "should handle sequence of permission operations" do
    TheRole2::PermissionLog.current_actor = @user_john
    # Create
    @user_john.permissions.create!(
      scope: nil,
      resource: "posts",
      action: "create",
      value: true,
      enabled: true
    )

    @user_john.preload_permissions!
    assert @user_john.has_permission?("posts::create")

    # Disable
    @user_john.disable_permission!("posts::create")
    assert_not @user_john.has_permission?("posts::create")

    # Enable
    @user_john.enable_permission!("posts::create")
    assert @user_john.has_permission?("posts::create")

    # Delete
    @user_john.delete_permission!("posts::create")
    assert_not @user_john.has_permission?("posts::create")
    assert_equal 0, @user_john.permissions.count
  end

  # Test Case 17: Cache with multiple permissions
  test "should cache multiple permissions correctly" do
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

  # Test Case 18: Permission value is preserved in cache
  test "should preserve permission value in cache" do
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

    hash = @user_john.permissions_hash

    assert_equal true, hash["posts::create"]
    assert_equal false, hash["posts::destroy"]
  end
end
