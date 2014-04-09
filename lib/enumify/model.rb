module Enumify
  module Model
    def enum(parameter, vals=[], opts={})

      validates_inclusion_of parameter, :in => vals, :allow_nil => !!opts[:allow_nil]

      const_set("#{parameter.to_s.pluralize.upcase}", vals)

      define_method "#{parameter.to_s}" do
        attr = read_attribute(parameter)
        (attr.nil? || attr.empty?) ? nil : attr.to_sym
      end

      define_method "#{parameter.to_s}=" do |value|
        send("_set_#{parameter.to_s}", value, false)
      end

      self.class_eval do

        private

        define_method "_set_#{parameter.to_s}" do |value, should_save|

          value = value and value.to_sym
          old = read_attribute(parameter) ? read_attribute(parameter).to_sym : nil
          return value if old == value
          write_attribute(parameter, (value and value.to_s))
          save if should_save
          send("#{parameter.to_s}_changed", old, value) if respond_to?("#{parameter.to_s}_changed", true) and !old.nil?
          return value
        end

      end

      vals.each do |val|
        raise "Collision in enum values method #{val}" if respond_to?("#{val.to_s}?") or respond_to?("#{val.to_s}!") or respond_to?("#{val.to_s}")

        define_method "#{val.to_s}?" do
          send("#{parameter.to_s}") == val
        end

        define_method "#{val.to_s}!" do
          send("_set_#{parameter.to_s}", val, true)
        end

        scope val.to_sym, lambda { where(parameter.to_sym => val.to_s) }
      end

      # We want to first define all the "positive" scopes and only then define
      # the "negation scopes", to make sure they don't override previous scopes
      vals.each do |val|
        # We need to prefix the field with the table name since if this scope will
        # be used in a joined query with other models that have the same enum field then
        # it will fail on ambiguous column name.
        unless respond_to?("not_#{val}")
          scope "not_#{val}", lambda { where("#{self.table_name}.#{parameter} != ?", val.to_s) }
        end
      end

    end

  end

end
