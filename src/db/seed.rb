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
            name TEXT NOT NULL,
            description TEXT,
            director TEXT,
            year TEXT
        )')
    end
    
    def self.seed_data
        puts "  * Seeding tables"
        movies = [
            {name: 'testmovie 1'},
        ]
    
        movies.each do |contact|
            db.execute('INSERT INTO movies (name) VALUES (?)', contact[:name])
        end
    end
end
