# frozen_string_literal: true

module Decidim
  module Debates
    # A command with all the business logic when a user updates a debate.
    class UpdateDebate < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # debate - the debate to update.
      def initialize(form, current_user, debate)
        @form = form
        @current_user = current_user
        @debate = debate
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the debate.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless debate.editable_by?(current_user)

        update_debate
        broadcast(:ok, debate)
      end

      private

      attr_reader :form, :debate, :current_user

      def organization
        @organization ||= form.current_component.organization
      end

      def i18n_field(field)
        organization.available_locales.inject({}) do |i18n, locale|
          i18n.update(locale => field)
        end
      end

      def update_debate
        @debate = Decidim.traceability.update!(
          @debate,
          current_user,
          attributes,
          visibility: "public-only"
        )
      end

      def attributes
        {
          category: form.category,
          title: i18n_field(form.title),
          description: i18n_field(form.description)
        }
      end
    end
  end
end
