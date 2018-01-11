class @SingleGenreArtistsReader

	GENRE_ARTIST_READER_SCRIPT_URL = "php/genre_artist_reader.php"

	constructor: ( @genre, @readAllArtists, @parentContext ) ->

		console.log "Started reader for genre #{ @genre }, readAllArtists = ", @readAllArtists


	read: () ->
		
		data = "genre=" + @genre + "&readAll=" + @readAllArtists

		onTheFlyData = {
			genre: @genre
		}

		AjaxUtils.sendAjax( 'GET', GENRE_ARTIST_READER_SCRIPT_URL, this, @_genreReadingSuccess, @_genreReadingError, data, onTheFlyData )

  
	_genreReadingSuccess: ( data, onTheFlyData ) ->
		data = JSON.parse( data )
		@parentContext.genreReadingDone( onTheFlyData.genre, data )


	_genreReadingError: ( xhr, status ) ->
		console.log "Error while reading genre data"
		console.log xhr
		console.log status

$ ->
	console.log "@SingleGenreArtistsReader loaded"