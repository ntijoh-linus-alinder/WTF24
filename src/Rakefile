task :seed do 
    require_relative './db/seed'
    Seeder.seed!
end



task :dev do
    port = 9292
    port_in_use = system("lsof -i:#{port}", out: '/dev/null')
    if port_in_use
        puts "port #{port} is in use, run `sudo killall ruby` to kill existing server"
        exit 0
    else
        puts 'Launching server on port #{port}'
        puts '  press `r` for forced restart, `q` to quit'
        puts "  http://localhost:#{9292}"
        system('rerun rackup --force-polling  --ignore "*.{erb,slim,js,css}"')
    end
end