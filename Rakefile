require 'sqlite3'
require "sequel/core"

namespace :db do
  task :setup do
    ROM::SQL::RakeSupport.env = ROM.container(:sql, "sqlite://#{Dir.pwd}/bof-o-matic.sqlite3")
  end

  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect("sqlite://#{Dir.pwd}/bof-o-matic.sqlite3") do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end

  task :fill do
    system("sqlite3 bof-o-matic.sqlite3 -init add-test-data.sql .quit")
  end
end

