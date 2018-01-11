class @GenreArtistsCrawler

	constructor: ( @parentContext, @callbackFunction ) ->

		console.log "Hello from the crawler side \n\n"
		@genres = AppData.getAvailableGenres()
  
		@currentGenreIndex = 0
		@currentGenre      = @genres[ @currentGenreIndex ]

		@singleGenreArtistsCrawler = new SingleGenreArtistsCrawler( @currentGenre, this )
		@singleGenreArtistsCrawler.crawl()


	genreCrawlingDone: ( genre ) ->

		console.log "Done crawling genre #{ genre } \n\n"

		if @currentGenreIndex is @genres.length - 1
			console.log "\n Finished crawling all genres"
			@callbackFunction.call( @parentContext )
			return

		@currentGenre = @genres[ ++@currentGenreIndex ]
		@singleGenreArtistsCrawler = new SingleGenreArtistsCrawler( @currentGenre, this )
		@singleGenreArtistsCrawler.crawl()


	@crawl: ( parentContext ) ->
		console.log "Crawl please"
		@genreArtistsCrawler = new GenreArtistsCrawler( parentContext )


$ ->
	console.log "@GenreArtistsCrawler loaded"