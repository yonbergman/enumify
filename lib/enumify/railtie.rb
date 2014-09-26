module Enumify
  class Railtie < Rails::Railtie
    initializer 'enumify.model' do
      ActiveSupport.on_load :active_record do
        include Enumify::Model
      end
    end
  end
end