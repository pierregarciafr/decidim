# frozen_string_literal: true

module Decidim
  module Debates
    class DiffRenderer < BaseDiffRenderer
      private

      # Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          title: :string,
          description: :string,
          information_updates: :string,
          instructions: :string,
          start_time: :string,
          end_time: :string
        }
      end

      def debate
        @debate ||= Debate.find_by(id: version.item_id)
      end
    end
  end
end
