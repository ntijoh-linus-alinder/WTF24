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
        
        @data = db.execute('SELECT * FROM movies')
        erb :'/movies/index'
    end
    
    get '/movies/new' do
        @all_geaneras = db.execute('SELECT * FROM geaneras')
        erb :'/movies/new'
    end

    post '/movies' do 
        title = params['title']
        description = params['description'] 
        year = params['year'] 

        geanera_ids = params['geanera_id'] 
        p geanera_ids 
        image = params["image"]
        File.open('public/img/' + image[:filename], "w") do |f|
            f.write(image[:tempfile].read)
        end

        query = 'INSERT INTO movies (title,description,year,image) VALUES (?,?,?,?) RETURNING *'

        result = db.execute(query,title,description,year,"img/"+image[:filename]).first

        geanera_ids.each do |geanera|
            p geanera
            db.execute('INSERT INTO movies_geaneras (geanera_id, movie_id) VALUES (?,?)', geanera, result['id'])
        end
        
        redirect "/movies/#{result['id']}"   
    end




    get '/movies/:id' do
        @data = db.execute('SELECT * FROM movies WHERE id = ?', params[:id])

        @joined_data = db.execute('SELECT * FROM movies
            INNER JOIN movies_geaneras ON movies.id = movies_geaneras.movie_id
            INNER JOIN geaneras ON geaneras.id = movies_geaneras.geanera_id
            WHERE movies.id = ?', params[:id])

        erb :'/movies/id'
    end
end