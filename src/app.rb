class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        redirect '/movies'
    end

    get '/movies' do
        query = '
        select * FROM movies
        JOIN movies_geaneras ON movies.id = movies_geaneras.movie_id
        JOIN geaneras ON movies_geaneras.id = geaneras.id
        '

        @data = db.execute('SELECT * FROM movies')
        erb :'/movies/index'
    end
    
    get '/movies/new' do
        erb :'/movies/new'
    end

    post '/movies' do 
        title = params['title']
        description = params['description'] 
        year = params['year'] 
        image = params["image"]
        File.open('public/img/' + image[:filename], "w") do |f|
            f.write(image[:tempfile].read)
        end

        query = 'INSERT INTO movies (title,description,year,image) VALUES (?,?,?,?) RETURNING *'
        result = db.execute(query,title,description,year,"img/"+image[:filename]).first
        redirect "/movies/#{result['id']}" 
    end




    get '/movies/:id' do
        @data = db.execute('SELECT * FROM movies WHERE id = ?', params[:id])
        erb :'/movies/id'
    end
end