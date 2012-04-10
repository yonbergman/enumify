module Enumify
  module Model
    def enum(parameter, opts=[])

      validates_inclusion_of parameter, :in => opts

      const_set("#{parameter.to_s.pluralize.upcase}", opts)

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

          value = value.to_sym
          old = read_attribute(parameter) ? read_attribute(parameter).to_sym : nil
          write_attribute(parameter, value.to_s)
          save if should_save
          send("#{parameter.to_s}_changed", old, value) if respond_to?("#{parameter.to_s}_changed", true) and old != value and !old.nil?
          return value
        end
      end

      opts.each do |opt|
        raise "Collision in enum values method #{opt}" if respond_to?("#{opt.to_s}?") or respond_to?("#{opt.to_s}!") or respond_to?("#{opt.to_s}")

        define_method "#{opt.to_s}?" do
            send("#{parameter.to_s}") == opt
        end

        define_method "#{opt.to_s}!" do
            send("_set_#{parameter.to_s}", opt, true)
        end


        scope opt.to_sym, where(parameter.to_sym => opt.to_s)
        # We need to prefix the field with the table name since if this scope will
        # be used in a joined query with other models that have the same field then
        # it will fail on ambiguous column name.
        scope "not_#{opt}".to_sym, where("#{self.table_name}.#{parameter} != ?", opt.to_s)
      end

    end

  end
end
