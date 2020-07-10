# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslatableLengthValidator do
    subject { record }

    let(:base_record_class) do
      Class.new(Decidim::Form) do
        include TranslatableAttributes
        mimic :participatory_process
        attribute :current_organization, Decidim::Organization
        translatable_attribute :description, String
      end
    end
    let(:record) do
      record_class.from_params({ participatory_process: { description: description } }, current_organization: organization)
    end
    let(:organization) do
      build(
        :organization,
        available_locales: available_locales,
        default_locale: default_locale
      )
    end
    let(:available_locales) { %w(en ca) }
    let(:default_locale) { :en }
    let(:description) do
      {
        ca: "Descripció",
        en: "Description"
      }
    end

    context "when it's allowed to be blank" do
      let(:record_class) do
        Class.new(base_record_class) do
          mimic :participatory_process
          validates :description, translatable_length: { minimum: 10, allow_blank: true }
        end
      end

      context "and there's no content" do
        let(:description) { {} }
        it { is_expected.to be_valid }
      end

      context "and there's content" do
        it { is_expected.to be_valid }
      end
    end

    context "when it's not allowed to be blank" do
      let(:record_class) do
        Class.new(base_record_class) do
          mimic :participatory_process
          validates :description, translatable_length: { minimum: 1 }
        end
      end

      context "and there's no content" do
        let(:description) { {} }
        it { is_expected.not_to be_valid }
      end

      context "and there's content" do
        it { is_expected.to be_valid }
      end
    end

    context "when there's a minimum validation" do
      let(:record_class) do
        Class.new(base_record_class) do
          mimic :participatory_process
          validates :description, translatable_length: { minimum: 15 }
        end
      end

      context "and the content is too short" do
        let(:description) { { en: "Description" } }

        it { is_expected.not_to be_valid }
      end

      context "and the content is long enough" do
        let(:description) { { en: "Long description" } }

        it { is_expected.to be_valid }
      end
    end

    context "when there's a maximum validation" do
      let(:record_class) do
        Class.new(base_record_class) do
          mimic :participatory_process
          validates :description, translatable_length: { maximum: 12 }
        end
      end

      context "and the content is not too long" do
        let(:description) { { en: "Description" } }

        it { is_expected.to be_valid }
      end

      context "and the content is too long" do
        let(:description) { { en: "Long description" } }

        it { is_expected.not_to be_valid }
      end
    end

    context "when there's content in non-default locales" do
      let(:record_class) do
        Class.new(base_record_class) do
          mimic :participatory_process
          validates :description, translatable_length: { minimum: 15 }
        end
      end

      it "validates them too" do
        expect(record).not_to be_valid
        expect(record.errors[:description_ca]).to include("is too short (under 15 characters)")
      end
    end
  end
end

