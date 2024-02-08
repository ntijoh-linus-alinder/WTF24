require 'sqlite3'

class Seeder

    def self.seed!
        puts "Seeding the DB"
        drop_tables
        create_tables
        seed_data
        puts "Seed complete"
    end

    private

    def self.db
        return @db if @db
        @db = SQLite3::Database.new('db/db.sqlite')
        @db.results_as_hash = true
        return @db
    end

    def self.drop_tables
        puts "  * Dropping Tables"
        db.execute('DROP TABLE IF EXISTS movies')
    end
    
    
    def self.create_tables
        puts "  * Creating tables"
        db.execute('CREATE TABLE movies(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            year TEXT,
            geanera TEXT,
            image BLOB
        )')
    end
    
    def self.seed_data
        puts "  * Seeding tables"
        movies = [
            {title: 'testmovie 1'},
        ]
    
        movies.each do |movie|
            db.execute('INSERT INTO movies (title) VALUES (?)', movie[:title])
        end
    end
end
