require 'enumify'
require 'active_record'

def set_database
  db_config = {:adapter => "sqlite3", :database => ":memory:"}
  ActiveRecord::Base.establish_connection(db_config)
  connection = ActiveRecord::Base.connection

  connection.create_table :models do |t|
    t.string :status
  end

  connection.create_table :other_models do |t|
    t.string :status
    t.references :model
  end
end

set_database

