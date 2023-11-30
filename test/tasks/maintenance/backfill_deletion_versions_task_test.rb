# frozen_string_literal: true

require "test_helper"

class Maintenance::BackfillDeletionVersionsTaskTest < ActiveSupport::TestCase
  test "#collection" do
    assert_equal Deletion.all, Maintenance::BackfillDeletionVersionsTask.collection
  end

  test "#process" do
    version = create(:version)
    deletion = create(:deletion, version:)

    deletion.update_column(:version_id, nil)

    assert_nil deletion.version_id

    Maintenance::BackfillDeletionVersionsTask.process(deletion)

    assert_equal version.id, deletion.version_id
    assert_equal version, deletion.version

    assert_no_changes -> { deletion.reload.as_json } do
      Maintenance::BackfillDeletionVersionsTask.process(deletion)
    end
  end

  test "#process with deleted user" do
    version = create(:version)
    deletion = create(:deletion, version:)

    deletion.update_column(:version_id, nil)

    assert_nil deletion.version_id

    deletion.user.destroy!

    Maintenance::BackfillDeletionVersionsTask.process(deletion.reload)

    assert_equal version.id, deletion.version_id
    assert_equal version, deletion.version
  end
end