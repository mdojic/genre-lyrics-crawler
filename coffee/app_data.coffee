class @AppData

	# Genres for which to crawl
	GENRES = ["black", "death", "doom", "thrash"]

	DEBUG_MODE = false

	REQUEST_TIMEOUT = 750

	LYRICS_WRITER_URL   = "php/lyrics_writer.php"
	PROGRESS_WRITER_URL = "php/progress_writer.php"
	PROGRESS_READER_URL = "php/progress_reader.php"
	FILTERED_ARTISTS_WRITER_URL = "php/filtered_genre_artist_writer.php"

	LAST_GENRE  = ""
	LAST_ARTIST = ""

	LOGGING_ON = false

	FILTER_ARTISTS = true


	@getAvailableGenres: () ->
		return GENRES

	@isDebugMode: () ->
		return DEBUG_MODE

	@getRequestTimeot: () ->
		return REQUEST_TIMEOUT

	@getLyricsWriterUrl: () ->
		return LYRICS_WRITER_URL

	@getProgressWriterUrl: () ->
		return PROGRESS_WRITER_URL

	@getProgressReaderUrl: () ->
		return PROGRESS_READER_URL

	@setLastGenre: ( genre ) ->
		LAST_GENRE = genre 
 
	@getLastGenre: () ->
		return LAST_GENRE

	@setLastArtist: ( artist ) ->
		LAST_ARTIST = artist 

	@getLastArtist: () ->
		return LAST_ARTIST

	@isLoggingOn: () ->
		return LOGGING_ON

	@doFilterArtists: () ->
		return FILTER_ARTISTS

	@getFilteredGenreArtistsWriterUrl: () ->
		return FILTERED_ARTISTS_WRITER_URL
