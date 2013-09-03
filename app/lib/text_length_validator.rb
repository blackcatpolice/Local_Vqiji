#
# FIXME:
#  length('abc') < 2?
#
class TextLengthValidator < ActiveModel::EachValidator
  
  MESSAGES  = { :maximum => :too_long }.freeze
  CHECKS    = { :maximum => :<= }.freeze

  RESERVED_OPTIONS  = [ :maximum, :too_long ]

  def initialize(options)
    super
  end

  def check_validity!
    keys = CHECKS.keys & options.keys

    if keys.empty?
      raise ArgumentError, 'Range unspecified. Specify the :maximum option.'
    end

    keys.each do |key|
      value = options[key]

      unless value.is_a?(Integer) && value >= 0
        raise ArgumentError, ":#{key} must be a nonnegative Integer"
      end
    end
  end

  def validate_each(record, attribute, value)
    value_length = length(value.respond_to?(:length) ? value : value.to_s)

    CHECKS.each do |key, validity_check|
      next unless check_value = options[key]
      next if value_length.send(validity_check, check_value)

      errors_options = options.except(*RESERVED_OPTIONS)
      errors_options[:count] = check_value

      default_message = options[MESSAGES[key]]
      errors_options[:message] ||= default_message if default_message

      record.errors.add(attribute, MESSAGES[key], errors_options)
    end
  end

  private
  
  def length(text)
    (text.gsub(/[^\u{0000}-\u{00ff}]/, "aa").length / 2.0).ceil
  end
end
