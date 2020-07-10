# frozen_string_literal: true

# A custom validator to check for length in I18n-enabled fields. In order to
# use it do the following:
#
#   validates :my_i18n_field, translatable_length: { minimum: 10, maximum: 100, allow_blank: true }
#
# This will automatically check for length for the default locale of the form
# object (or the `default_locale` of the form's organization) for the given field.
#
# If there's content for non-default locales, it will also check that the
# length is correct, buyt won't fail if there's no content.
class TranslatableLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    translated_attr = "#{attribute}_#{default_locale_for(record)}"
    value = record.send(translated_attr).to_s
    return record.errors.add(translated_attr, :blank) if value.blank? && !options[:allow_blank]

    minimum = options[:minimum] || 0
    maximum = options[:maximum] || Float::INFINITY

    record.current_organization.available_locales.each do |locale|
      translated_attr = "#{attribute}_#{locale}"
      length = record.send(translated_attr).to_s.length
      next unless length.positive?

      record.errors.add(translated_attr, :too_short) if length < minimum
      record.errors.add(translated_attr, :too_long) if length > maximum
    end
  end

  private

  def default_locale_for(record)
    return record.default_locale if record.respond_to?(:default_locale)

    if record.current_organization
      record.current_organization.default_locale
    else
      record.errors.add(:current_organization, :blank)
      []
    end
  end
end

