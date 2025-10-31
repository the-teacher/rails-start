module TheRole2
  module Concerns
    module UniqueWithinTimeWindow
      extend ActiveSupport::Concern

      MAX_TIME = Time.utc(9999,12,31,23,59,59)

      # Check that permission scope/resource/action combination is unique
      # within overlapping time windows for the same holder
      def unique_within_time_window(&block)
        unless block_given?
          raise ArgumentError, "TheRole2::Concerns::UniqueWithinTimeWindow#unique_within_time_window requires a block returning an ActiveRecord::Relation"
        end

        query = instance_exec(&block)

        # Find other permissions with same holder, scope, resource, action
        # query = TheRole2::Permission.where(
        #   holder_type: holder_type,
        #   holder_id: holder_id,
        #   scope: scope,
        #   resource: resource,
        #   action: action
        # )

        # Exclude current record if it's an update
        query = query.where.not(id: id) if persisted?

        # Check for time window overlaps
        query.each do |other|
          if time_windows_overlap?(other)
            errors.add(:base, "Permission with same scope/resource/action already exists in overlapping time window")
            return
          end
        end
      end

      private

      # Check if two permission time windows overlap
      # Two windows overlap if: end1 > start2 AND start1 < end2
      def time_windows_overlap?(other)
        # Determine effective time windows
        self_start = starts_at
        self_end = ends_at
        other_start = other.starts_at
        other_end = other.ends_at

        # If either has no start, it starts from past
        self_start = Time.at(0) if self_start.nil?
        other_start = Time.at(0) if other_start.nil?

        # If either has no end, it goes to future
        self_end = MAX_TIME if self_end.nil?
        other_end = MAX_TIME if other_end.nil?

        # Check overlap: end > other_start AND start < other_end
        self_end > other_start && self_start < other_end
      end
    end
  end
end
