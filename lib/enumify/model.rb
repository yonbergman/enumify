module Enumify
  module Model

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def enumify(parameter, vals=[], opts={})

        validates_inclusion_of parameter, :in => vals, :allow_nil => !!opts[:allow_nil]
        paramater_string = parameter.to_s

        prefix = ''
        if opts[:prefix] == true
          prefix = "#{paramater_string}_"
        elsif opts[:prefix].present?
          prefix = "#{opts[:prefix].to_s}_"
        end

        const_set("#{paramater_string.pluralize.upcase}", vals)

        define_method "#{paramater_string}" do
          attr = read_attribute(parameter)
          (attr.nil? || attr.empty?) ? nil : attr.to_sym
        end

        define_method "#{paramater_string}=" do |value|
          send("_set_#{paramater_string}", value, false)
        end

        self.class_eval do

          private

          define_method "_set_#{paramater_string}" do |value, should_save|

            value = value and value.to_sym
            old = read_attribute(parameter) ? read_attribute(parameter).to_sym : nil
            return value if old == value
            write_attribute(parameter, (value and value.to_s))
            save if should_save
            send("#{paramater_string}_changed", old, value) if respond_to?("#{paramater_string}_changed", true) and !old.nil?
            return value
          end

        end

        vals.each do |val|
          attribute = prefix + val.to_s
          query_method = "#{attribute}?"
          bang_method = "#{attribute}!"

          raise "Collision in enum values method #{attribute}" if respond_to?(query_method) or respond_to?(bang_method) or respond_to?(attribute)

          define_method query_method do
            send("#{paramater_string}") == val
          end

          define_method bang_method do
            send("_set_#{paramater_string}", val, true)
          end

          scope attribute.to_sym, lambda { where(parameter.to_sym => val.to_s) }
        end

        # We want to first define all the "positive" scopes and only then define
        # the "negation scopes", to make sure they don't override previous scopes
        vals.each do |val|
          # We need to prefix the field with the table name since if this scope will
          # be used in a joined query with other models that have the same enum field then
          # it will fail on ambiguous column name.
          negative_scope = "not_" + prefix + val.to_s
          unless respond_to?(negative_scope)
            scope negative_scope, lambda { where("#{self.table_name}.#{parameter} != ?", val.to_s) }
          end
        end
      end
      alias_method :enum, :enumify
    end

  end

end
