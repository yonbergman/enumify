module UrlFormatter
  class Railtie < Rails::Railtie
    initializer 'enumify.model' do
      ActiveSupport.on_load :active_record do
        extend Enumify::Model
      end
    end
  end
end