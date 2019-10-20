require './input_functions'
require 'ffi'

module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end

module VLC
    extend FFI::Library
    ffi_lib 'vlc'
    attach_function :version, :libvlc_get_version, [], :string
    attach_function :new, :libvlc_new, [:int, :int], :pointer
    attach_function :libvlc_media_new_path, [:pointer, :string], :pointer
    attach_function :libvlc_media_player_new_from_media, [:pointer], :pointer
    attach_function :play, :libvlc_media_player_play, [:pointer], :int
    attach_function :stop, :libvlc_media_player_stop, [:pointer], :int
    attach_function :pause, :libvlc_media_player_pause, [:pointer], :int
end


$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']
$album_file = nil

    class Album
        attr_accessor :title, :artist, :genre, :tracks

        def initialize (title, artist, genre, tracks)
            @title = title
            @artist = artist
            @genre = genre
            @tracks = tracks
        end
    end
  
  class Track
      attr_accessor :name, :location
  
      def initialize (name, location)
          @name = name
          @location = location
      end
  end



# 5 Write Changes
def write_track track, music_file
    music_file.puts track.name
    music_file.puts track.location
end

def write_tracks tracks, music_file
    count = tracks.length
    music_file.puts(count)
    i = 0
    while (i < count)
        write_track(tracks[i], music_file)
        i += 1
    end
end

def write_album album, music_file
    music_file.puts album.title
    music_file.puts album.artist
    music_file.puts album.genre
    write_tracks(album.tracks, music_file)
    
end

def write_albums albums, music_file
    count = albums.length
    music_file.puts(count)
    i = 0
    while (i < count)
        write_album albums[i], music_file
        i += 1
    end
end

def write_changes albums
    if $album_file
        music_file = File.new($album_file, "w")
        if music_file
            write_albums albums, music_file 
            music_file.close()
        else
            puts "Unable to open file to read!" # this doesn't work when incorrect value given
        end
    else
        puts 'Unable to read filename'
    end
    puts 'Music Library Overwritten'
end 



# 4 Update Album
def update_album_genre album
    puts('The current album genre is: ', $genre_names[album.genre])
    puts('Select New Genre')
    puts('1 Pop, 2 Classic, 3 Jazz & 4 Rock')
    new_genre = read_integer('Enter number: ')
    album.genre = new_genre
end

def update_album_title album
    puts('The current album title is: ', album.title)
    title = read_string('Enter a new title for the album')
    album.title = title
end

def update_album_artist album
    puts('The current album title is: ', album.artist)
    artist = read_string('Enter a new artist for the album')
    album.artist = artist
end

def update_track_title track
    title = read_string('Enter a new title for the track')
    track.title = title
end

def update_track_location track
    location = read_string('Enter a new location for the track')
    track.location = location
end

def update_album_track track
    print_track

    finished = false
    begin
      puts 'Update Track:'
      puts '1 - Update Track Title'
      puts '2 - Update Track Location'

      choice = read_integer_in_range("Option: ", 1, 2)
          case choice
          when 1
              update_track_title track
          when 2
              update_track_location track
          end
      finished = read_string('Press ENTER...')
    end until finished
end

def update_album_tracks album
    print_title_tracks album.tracks
    puts('Select Track ID')
    track_id = read_integer_in_range('Enter number: ', 0, tracks.count-1)
    update_album_track album.tracks[track_id]
end

def update_album album
    finished = false
    begin
      puts 'Update Albums:'
      puts '1 - Update Album Artist'
      puts '2 - Update Album Title'
      puts '3 - Update Album Genre'

      choice = read_integer_in_range("Option: ", 1, 3)
          case choice
          when 1
              update_album_artist album
          when 2
              update_album_title album
          when 3
              update_album_genre album
          when 4
              update_album_tracks album
          end
      finished = read_string('Press ENTER...')
    end until finished
end

def update_albums albums
    finished = false
    album = nil
    begin
      puts 'Update Albums:'
      puts '1 - Search by ID'
      puts '2 - Search by genre/name'
      choice = read_integer_in_range("Option: ", 1, 2)
          case choice
          when 1
              update_album search_by_id albums
          when 2
              update_album search_album albums
          else
              puts 'Please select again'
          end
      finished = read_string('Press ENTER...')
    end until finished
end

# 3.2 Search < 3 Play Album

def search_albums_by_genre albums
    print_album_genres(albums)
    puts('Select Album ID')
    id = read_integer_in_range('Enter number: ', 0, albums.count-1  )

    print_album_title_and_tracks(albums[id])
    return albums[id]    
end

def search_albums_by_name albums
    album_title = read_string('Enter Album Name to Search: ')
    count = albums.length
    i = 0
    while (i < count)
      if album_title == albums[i].title
        print_album_title_and_tracks albums[i]
        return albums[i]
      end
    end
end

def search_album albums
    finished = false
    begin
      puts 'Search Albums:'
      puts '1 - Search by Genre'
      puts '2 - Search by Name'
      choice = read_integer_in_range("Option: ", 1, 2)
        case choice
        when 1
            return search_albums_by_genre(albums)
        when 2
            return search_albums_by_name(albums)
        else
            puts 'Please select again'
        end
    finished = read_string('Press ENTER...')
    end until finished
end

# 3.1 Play by ID < 3 Play Album
def print_title_track track
	puts('Track title is: ' + track.name)
  	puts('Track file location is: ' + track.location)
end

def print_title_tracks tracks
	count = tracks.length
	i = 0
    while (i < count)
      puts('Track id is: ' + i.to_s)
	  print_title_track(tracks[i]) # use: tracks[x] to access each track.
	  i += 1
	end
end

def print_album_title_and_tracks album
    puts album.title.to_s
    # print out the tracks
    print_title_tracks(album.tracks) 
end

def print_albums_id_tracks albums
	count = albums.length
	i = 0
    while (i < count)
      print ' ID is ' + i.to_s + " for: "
      print_album_title_and_tracks(albums[i]) # use: tracks[x] to access each track.
	  i += 1
	end
end

def print_album_title album
    puts  album.title.to_s
end

def print_albums_id albums
	count = albums.length
	i = 0
    while (i < count)
      print ' ID is ' + i.to_s + " for: "
      print_album_title(albums[i]) # use: tracks[x] to access each track.
	  i += 1
	end
end

def search_by_id(albums)
    print_albums_id(albums)
    puts('Select Album ID')
    id = read_integer_in_range('Enter number: ', 0, albums.count-1  )

    print_album_title_and_tracks(albums[id])
    return albums[id]
end

# 3 Play Album

def play_tracks tracks 
    puts('Select Track ID')

    track_id = read_integer_in_range('Enter number: ', 0, tracks.count-1)
    trackname = File.join(Dir.pwd, tracks[track_id].location)
    trackname =  trackname.split(".mp3")[0] + ".mp3"

    vlc    = VLC.new(0, 0)
    media  = VLC.libvlc_media_new_path(vlc, trackname)
    player = VLC.libvlc_media_player_new_from_media(media)
    VLC.play(player)

    begin 
        finished = false
        finished = read_string('Press ENTER to stop...')
    end until finished
    VLC.stop(player)
end

def play_album(albums)
    finished = false
    album = nil
    begin
      puts 'Play Albums:'
      puts '1 - Play by ID'
      puts '2 - Search'
      choice = read_integer_in_range("Option: ", 1, 2)
        case choice
        when 1
            album = search_by_id(albums)
            play_tracks(album.tracks)
        when 2
            album = search_album(albums)
            play_tracks(album.tracks)
        else
            puts 'Please select again'
        end
      finished = read_string('Press ENTER...')
    end until finished
end

# 2.2 Print Ablum Genre < 2 Menu Display Albums
def print_album_genres albums
    puts('Select Genre')
    puts('1 Pop, 2 Classic, 3 Jazz & 4 Rock')
    search_genre = read_integer('Enter number: ')
    i = 0
    while i < albums.length
        if search_genre == albums[i].genre
            print_album(albums[i])
        end
        i += 1
    end
end

# 2.1 Print albums, album, tracks and track < 2 Menu Display Albums
def print_track track
	puts('Track title is: ' + track.name)
  	puts('Track file location is: ' + track.location)
end

def print_tracks tracks
	count = tracks.length
	i = 0
	while (i < count)
	  print_track(tracks[i]) # use: tracks[x] to access each track.
	  i += 1
	end
end

def print_album album
    puts 'Artist is: ' + album.artist.to_s
    puts 'Title is: ' + album.title.to_s
    puts 'Genre is ' +  $genre_names[album.genre]
    # print out the tracks
    print_tracks(album.tracks) 
end

def print_albums albums
	count = albums.length
	i = 0
    puts 'Album Count ID is: ' + albums.length.to_s
    while (i < count)
	  print_album(albums[i]) # use: tracks[x] to access each track.
	  i += 1
	end
end

# 2 Menu Display Albums
def display_albums(albums)
    finished = false
    begin
    puts 'Display Albums:'
    puts '1 - Display All'
    puts '2 - Display Genre'
    choice = read_integer_in_range("Option: ", 1, 2)
        case choice
        when 1
            print_albums(albums)
        when 2
            print_album_genres(albums)
        else
            puts 'Please select again'
        end
    finished = read_string('Press ENTER...')
    end until finished
end

# 1.1 Read albums, album, tracks and track < 1 Menu Read Album File
def read_track music_file
	name = music_file.gets.chomp
    location = music_file.gets
    track = Track.new(name, location)
    return track
end

def read_tracks music_file
	count = music_file.gets().to_i
  	tracks = Array.new
        while (0 < count)
            track = read_track(music_file)
            tracks << track
            count -= 1
        end
	return tracks
end

def read_album music_file
		album_artist = music_file.gets
		album_title = music_file.gets
		album_genre = music_file.gets.to_i
	  	tracks = read_tracks(music_file) # tracks or music_file
	 	album = Album.new(album_artist, album_title, album_genre, tracks)
	  	return album
  end

def read_albums music_file
	count = music_file.gets().to_i
	albums = Array.new
        while (0 < count)
            album = read_album(music_file)
            albums << album
            count -= 1
        end
	return albums
end

# 1 Menu Read Album File
def read_album_file
    finished = false
    begin
    $album_file = read_string('Enter File Name ( aka album.txt): ')
    music_file = File.new($album_file, "r")
        if music_file
            albums = read_albums(music_file)
            music_file.close()
        else
            puts "Unable to open file to read!" # this doesn't work when incorrect value given
        end
    puts 'Music Library Loaded'
    finished = read_string('Press ENTER...')
    end until finished
    return albums
end

# 0 Main Menu
def main_menu_albums
    finished = false
    begin
    puts 'Main Menu:'
    puts '1 - Read Album File'
    puts '2 - Display Album Info'
    puts '3 - Play Album'
    puts '4 - Update Album'
    puts '5 - Exit'
    choice = read_integer_in_range("Option: ", 1, 5)
        case choice
        when 1
            albums = read_album_file
        when 2
            display_albums(albums)
        when 3
            play_album(albums)
        when 4
            update_albums(albums)
        when 5
            write_changes albums
            finished = true
        else
            puts 'Please select again'
        end
    end until finished
end

def main
    main_menu_albums
end

main