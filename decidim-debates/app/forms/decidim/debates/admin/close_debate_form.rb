# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This class holds a Form to close debates from Decidim's admin views.
      class CloseDebateForm < Decidim::Form
        include TranslatableAttributes

        mimic :debate

        translatable_attribute :conclusions, String
        attribute :debate, Debate

        validates :debate, presence: true
        validates :conclusions, translatable_presence: true
        validate :user_can_close_debate

        def closed_at
          debate&.closed_at || Time.current
        end

        private

        def user_can_close_debate
          errors.add(:debate, :invalid) unless debate.official?
        end
      end
    end
  end
end
