class @Main

	# Boolean flag 
	# TRUE  : Crawl artists by genres first, then read them and continue
	# FALSE : Read genre artists from files and continue 
	CRAWL_GENRES = false
 	

	##########################################################################################
	###### 									Script init									######
	##########################################################################################

	constructor: () ->

		# Check if logging should be turned off (turn off when not in debug mode)
		turnOffLogging = not AppData.isLoggingOn()

		if turnOffLogging
			console.log "App isn't in debug mode, turn off logging"
			console.log = () ->
		else 
			console.log "App is in debug mode, logging on"

		@genreData         = null	
		@filteredGenreData = null

		@_loadProgress()
    

	##########################################################################################
	###### 							Loading last progress								######
	##########################################################################################

	_loadProgress: () ->

		progressReaderUrl = AppData.getProgressReaderUrl()
		AjaxUtils.sendAjax( 'GET', progressReaderUrl, this, @_progressLoaded, @_progressLoadingError, null )


	_progressLoaded: ( data, onTheFlyData ) ->

		console.log "/// /// _progressLoaded: ", data

		progress   = JSON.parse( data ) 
		lastGenre  = progress.genre 
		lastArtist = progress.artist

		AppData.setLastGenre( lastGenre )
		AppData.setLastArtist( lastArtist )

		@_startWork()


	_progressLoadingError: () ->
		console.log "Error while loading progress"


	_startWork: () ->

		# Determine whether to crawl artists or to read them from files
		if CRAWL_GENRES
			console.log "Crawl genres"
			@_crawlGenreArtists()
		else 
			console.log "Skip crawling genres"
			@_readGenreArtists()


	##########################################################################################
	###### 							Crawling genre artists								######
	##########################################################################################

	# Crawl genre artists
	_crawlGenreArtists: () ->
		GenreArtistsCrawler.crawl( this, @allGenresCrawled )


	# Success function when all genre artists are crawled
	allGenresCrawled: () ->
		@_readGenreArtists()



	##########################################################################################
	###### 						Reading genre artists from files						######
	##########################################################################################

	# Read genre artists from files
	_readGenreArtists: () ->
		console.log "||| _readGenreArtists |||"

		# Check if artists need to be filtered
		filterArtists = AppData.doFilterArtists()
		console.log "||| filterArtists = ", filterArtists

		# If the artists need to be filtered, we will read all artists and then filter them
		# Otherwise, we will read already filtered artists
		readAllArtists = filterArtists
		console.log "||| readAllArtists = ", readAllArtists

		GenreArtistsReader.read( this, @allGenresRead, readAllArtists )


	# Success function when all genre artists are read
	allGenresRead: ( data ) ->

		console.log "@@@ @@@ @@@ @@@ @@@ allGenresRead @@@ @@@ @@@ @@@ @@@"

		@genreData = data

		@filteredGenreData = {}

		filterArtists = AppData.doFilterArtists()

		if filterArtists

			dataForServer = []

			for genre, singleGenreData of @genreData 
				filteredData = GenreProcessingUtils.filterGenreArtists( singleGenreData, genre )
				@filteredGenreData[genre] = filteredData

		else 
			@filteredGenreData = @genreData

		console.log "*** Filtered genre data: "
		console.log @filteredGenreData

		# Crawl darklyrics.com using @filteredGenreData
		@_crawlLyrics()



	##########################################################################################
	###### 						Crawling artist lyrics									######
	##########################################################################################

	# Crawl lyrics of filtered artists
	_crawlLyrics: () ->
		console.log "Crawl lyrics, @filteredGenreData = ", @filteredGenreData
		LyricsCrawler.crawl( this, @allLyricsCrawled, @filteredGenreData )


	allLyricsCrawled: ( lyricsData ) ->

		console.log "--------------------------------------------------------------------"
		console.log "\t\t All lyrics crawled  "
		console.log "--------------------------------------------------------------------"

$ ->
	console.log "@Main loaded"
	main = new Main()