# frozen_string_literal: true

module Decidim
  module Debates
    # This class holds a Form to create/update debates from Decidim's public views.
    class DebateForm < Decidim::Form
      include TranslatableAttributes

      attribute :title, String
      attribute :description, String
      attribute :category_id, Integer
      attribute :user_group_id, Integer

      validates :title, presence: true
      validates :description, presence: true

      validates :category, presence: true, if: ->(form) { form.category_id.present? }

      def map_model(debate)
        super

        # Debates can be translated in different languages from the admin but
        # the public form doesn't allow it. When a user creates a debate the
        # text is the same for all languages.
        self.title = debate.title.values.first
        self.description = debate.description.values.first
        self.user_group_id = debate.decidim_user_group_id

        if debate.category.present?
          self.category_id = debate.category.id
          @category = debate.category
        end
      end

      def category
        @category ||= current_component.categories.find_by(id: category_id)
      end
    end
  end
end
