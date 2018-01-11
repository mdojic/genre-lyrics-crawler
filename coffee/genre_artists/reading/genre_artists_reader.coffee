class @GenreArtistsReader

	constructor: ( @parentContext, @callbackFunction, @readAllArtists ) ->

		console.log "Hello from the reader side, readAllArtists = #{ @readAllArtists } \n\n"

		@genres = AppData.getAvailableGenres()

		@genresData = {}
 
		@currentGenreIndex = 0
		@currentGenre      = @genres[ @currentGenreIndex ]

		@singleGenreArtistsReader = new SingleGenreArtistsReader( @currentGenre, @readAllArtists, this )
		@singleGenreArtistsReader.read()


	genreReadingDone: ( genre, data ) ->

		console.log "Done reading genre #{ genre } \n\n"

		@genresData[genre] = data

		if @currentGenreIndex is @genres.length - 1
			console.log "\n Finished reading all genres"
			@callbackFunction.call( @parentContext, @genresData )
			return

		@currentGenre = @genres[ ++@currentGenreIndex ]
		@singleGenreArtistsReader = new SingleGenreArtistsReader( @currentGenre, @readAllArtists, this )
		@singleGenreArtistsReader.read()


	@read: ( parentContext, callbackFunction, readAllArtists ) ->
		@genreArtistsReader = new GenreArtistsReader( parentContext, callbackFunction, readAllArtists )
		

$ ->
	console.log "@GenreArtistsReader loaded"