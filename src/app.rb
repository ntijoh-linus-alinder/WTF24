class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        erb :index
    end
    get '/movies' do
        @data = db.execute('SELECT * FROM movies')
        erb :movies
    end
    


    get '/movies/:id' do
        @data = db.execute('SELECT * FROM movies WHERE id = ?', params[:id])
        erb :id
    end
end