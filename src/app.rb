class App < Sinatra::Base
    enable :session

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    before do
        @username = session[:username]
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
        @all_cast = db.execute('SELECT * FROM casts')
        erb :'/movies/new'
    end

    post '/movies' do 
        title = params['title']
        description = params['description'] 
        year = params['year'] 
    
        geanera_ids = params['geanera_id'] 
        cast_id = params['cast_id']
        selected_actors = params['actors'] || []
        image = params["image"]
        
        if image && image[:filename]
            File.open('public/img/' + image[:filename], "w") do |f|
                f.write(image[:tempfile].read)
            end
            image_path = "img/#{image[:filename]}"
        else
            image_path = nil
        end
    
        query = 'INSERT INTO movies (title,description,year,image) VALUES (?,?,?,?) RETURNING *'
    
        result = db.execute(query, title, description, year, image_path).first
    
        unless geanera_ids.nil? || geanera_ids.empty?
            geanera_ids.each do |geanera|
                db.execute('INSERT INTO movies_geaneras (geanera_id, movie_id) VALUES (?,?)', geanera, result['id'])
            end
        end
    
        selected_actors.each do |actor_id|
            db.execute('INSERT INTO movies_casts (movie_id, cast_id) VALUES (?, ?)', result['id'], actor_id)
        end
    
        db.execute('INSERT INTO movies_casts (movie_id, cast_id) VALUES (?, ?)', result['id'], cast_id)
        
        redirect "/movies/#{result['id']}"   
    end


    get '/movies/:id/edit' do
        @movie = db.execute('SELECT * FROM movies WHERE id = ?', params[:id]).first
        @all_geaneras = db.execute('SELECT * FROM geaneras')
        @movie_geaneras = db.execute('SELECT geanera_id FROM movies_geaneras WHERE movie_id = ?', params[:id]).map {|row| row['geanera_id'].to_i}
        @all_cast = db.execute('SELECT * FROM casts')
        @cast_join = db.execute('SELECT * FROM movies
            INNER JOIN movies_casts ON movies.id = movies_casts.movie_id
            INNER JOIN casts ON casts.id = movies_casts.cast_id
            WHERE movies.id = ?', params[:id])
        erb :'/movies/edit'

    end
    

    get '/actors/new' do
        @all_cast = db.execute('SELECT * FROM casts')
        erb :'/actors/new'
    end

    get '/actors' do
        erb :'/actors/index'
    end

    post '/actors' do 
        name = params['name']
        db.execute('INSERT INTO casts (name) VALUES (?)', name)
        redirect "/actors/new" 
    end

    post '/movies/:id/edit' do
        id = params[:id]
        title = params['title']
        description = params['description'] 
        year = params['year'] 
        geanera_ids = params['geanera_id']
        selected_actors = params['actors'] || []
        cast_id = params['cast_id']
        image = params["image"]
        
        if image && image[:filename]
            old_image_path = db.execute('SELECT image FROM movies WHERE id = ?', id).first['image']
            if old_image_path && File.exist?('public/' + old_image_path)
                File.delete('public/' + old_image_path)
            end
    
            File.open('public/img/' + image[:filename], "w") do |f|
                f.write(image[:tempfile].read)
            end
            image_path = "img/#{image[:filename]}"
        else
            image_path = nil
        end
    
        if image_path.nil?
            query = 'UPDATE movies SET title = ?, description = ?, year = ? WHERE id = ?'
            result = db.execute(query, title, description, year, id)
        else 
            query = "UPDATE movies SET title = ?, description = ?, year = ?, image = ? WHERE id = ?"
            result = db.execute(query, title, description, year, image_path, id)
        end
    
        db.execute('DELETE FROM movies_geaneras WHERE movie_id = ?', id)
    
        geanera_ids.each do |geanera|
            db.execute('INSERT INTO movies_geaneras (geanera_id, movie_id) VALUES (?,?)', geanera, id)
        end

        selected_actors.each do |actor_id|
            db.execute('INSERT INTO movies_casts (movie_id, cast_id) VALUES (?, ?)', id, actor_id)
        end
    
        db.execute('INSERT INTO movies_casts (movie_id, cast_id) VALUES (?, ?)', id, cast_id)
    
        redirect "/movies/#{id}"
    end
    
    

    post '/movies/:id/delete' do
        id = params[:id]

        db.execute('DELETE FROM movies WHERE id = ?', id)
        db.execute('DELETE FROM movies_geaneras WHERE movie_id = ?', id)
        db.execute('DELETE FROM movies_casts WHERE movie_id = ?', id.to_i)
        redirect "/movies"
    end
    
    

    get '/movies/:id' do
        @data = db.execute('SELECT * FROM movies WHERE id = ?', params[:id])
        @joined_data = db.execute('SELECT * FROM movies
            INNER JOIN movies_geaneras ON movies.id = movies_geaneras.movie_id
            INNER JOIN geaneras ON geaneras.id = movies_geaneras.geanera_id
            WHERE movies.id = ?', params[:id])

        @cast_join = db.execute('SELECT * FROM movies
            INNER JOIN movies_casts ON movies.id = movies_casts.movie_id
            INNER JOIN casts ON casts.id = movies_casts.cast_id
            WHERE movies.id = ?', params[:id])

        erb :'/movies/id'
    end

    get '/login' do

        erb :'/users/index'
    end
    get '/register' do

        erb :'/users/register'
    end
    get '/users/edit' do

        erb :'/users/edit'
    end

    post '/register' do
        email = params['email']
        username = params['username']
        cleartext_password = params['password']
        hashed_password = BCrypt::Password.create(cleartext_password)

        db.execute('INSERT INTO users (email, username, password) VALUES (?, ?, ?)', email, username, hashed_password)
        redirect '/login'
    end

    post '/login' do
        username = params['username']
        cleartext_password = params['password'] 
      
        user = db.execute('SELECT * FROM users WHERE username = ?', username).first
        password_from_db = BCrypt::Password.new(user['password'])

        if password_from_db == cleartext_password 
          session[:user_id] = user['user_id'] 
          session[:username] = username  
          p "hej    "
          redirect '/movies'  
        else
          nil
        end

    end
end