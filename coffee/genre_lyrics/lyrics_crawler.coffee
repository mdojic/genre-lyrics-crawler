
# Class used for crawling lyrics for artists of different genres
class @LyricsCrawler

	constructor: ( @parentContext, @callbackFunction, @artistsData ) ->

		console.log "LyricsCrawler created"
		console.log "@artistsData = ", @artistsData

		# Flag to remember if any lyrics were sent to the server
		# Used to determine if a new file for storing lyrics should be created or not
		@sentLyricsToServer = false

		@writeGenreProgress = false

		# Get genres for which lyrics are being crawled
		@genres = Object.keys( @artistsData )

		# Get last started genre 
		lastStartedGenre = AppData.getLastGenre()
		console.log "/// lastStartedGenre = ", lastStartedGenre

		# Find index of last started genre
		for genre, index in @genres 
			@currentGenreIndex = index if genre is lastStartedGenre 

		console.log "/// @currentGenreIndex = ", @currentGenreIndex

		# For keeping track of the currently crawled genre
		@currentGenre = @genres[ @currentGenreIndex ]

		console.log "/// @currentGenre = ", @currentGenre

		# For checking if the last genre was crawled
		@lastGenreIndex = @genres.length - 1

		# Start crawling for lyrics of artists for the current genre
		@_crawlCurrentGenreArtists()


	# Crawl lyrics of artists for the current genre
	_crawlCurrentGenreArtists: () ->

		if @writeGenreProgress
			console.log "*&&& @writeGenreProgress TRUE"
			@_writeGenreProgress( @currentGenre )
		else 
			console.log "&&& @writeGenreProgress FALSE"
			@_startCrawl()
			@writeGenreProgress = true


	# Move on to the next genre for crawling
	_getNextGenre: () ->
		console.log "^^^ _getNextGenre"
		return @genres[ ++@currentGenreIndex ]


	# Success function when all artists from a single genre were crawled
	allGenreArtistsCrawled: ( genre ) ->

		console.log "*** All artists crawled for genre: ", genre

		# Check if artists of all genres were crawled
		if @currentGenreIndex is @lastGenreIndex

			console.log "=== Last genre, finished"

			# If artists of all genres were crawled, notify parent context
			@callbackFunction.call( @parentContext )

		else 
			# If there are still genres whose artists need to be crawled, crawl next genre's artists
			@currentGenre = @_getNextGenre()
			console.log "--- Not last genre, crawl next: ", @currentGenre

			@_crawlCurrentGenreArtists()


	_writeGenreProgress: ( genre ) ->

		console.log "--- _writeGenreProgress for genre #{genre}"

		progressWriterUrl = AppData.getProgressWriterUrl()
		data = {
			genre : genre
		}
		AjaxUtils.sendAjax("POST", progressWriterUrl, this, @_progressWritten, @_progressWritingError, data, genre )


	_progressWritten: ( data, onTheFlyData ) ->
		console.log "--- progress written for genre #{@currentGenre}"
		AppData.setLastArtist("")
		@_startCrawl()


	_progressWritingError: ( errorCode, errorMessage ) ->
		console.log "Error while writing progress"
		console.log errorMessage
		console.log errorCode


	_startCrawl: () ->

		artists = @artistsData[ @currentGenre ]
		genreLyricsCrawler = new GenreLyricsCrawler( this, @currentGenre, artists )
		genreLyricsCrawler.crawl()


	# Static function which creates a crawler and starts crawling for artist lyrics
	@crawl: ( parentContext, callbackFunction, artistsData ) ->
		console.log "Crawl lyrics: ", artistsData
		@lyricsCrawler = new LyricsCrawler( parentContext, callbackFunction, artistsData )



# Inner class for crawling artists of single genre
class GenreLyricsCrawler

	# Separator inserted between song lyrics
	LYRICS_SEPARATOR = "|$%:%$|"

	constructor: ( @parentContext, @genre, @artists ) ->

		console.log "$ $ $ @artists: ", @artists

		# Get last crawled artist
		lastStartedArtist = AppData.getLastArtist()

		console.log "$ $ $ lastStartedArtist = ", lastStartedArtist

		if not AppUtils.isEmptyData( lastStartedArtist )

			for artist, index in @artists 
				if artist.artistName is lastStartedArtist
					@currentArtistIndex = index 
					break
					
		else 
			@currentArtistIndex = 0

		# For keeping track of the artist whose lyrics are currently being crawled
		@currentArtist = @artists[ @currentArtistIndex ]

		console.log "$ $ $ @currentArtistIndex = ", @currentArtistIndex 
		console.log "$ $ $ @currentArtist = ", @currentArtist

		# For checking if all artists' lyrics have been crawled
		@lastArtistIndex = @artists.length - 1

		# For keeping lyrics for this genre
		@genreLyrics = []


	# Start crawling for lyrics
	crawl: () ->
		console.log "Crawl artist lyrics for genre: #{ @genre }"
		console.log "Artists: ", @artists

		# Crawl the first artist
		@_crawlCurrentArtist()


	# Crawl for lyrics of the current artist
	_crawlCurrentArtist: () ->

		console.log "Crawl lyrics for artist: ", @currentArtist
		@singleArtistLyricsCrawler = new SingleArtistLyricsCrawler( @currentArtist, this, @artistLyricsCrawlingDone )
		@singleArtistLyricsCrawler.crawl()


	# Success function when all lyrics for an artist were crawled
	artistLyricsCrawlingDone: ( artist, genre, lyrics ) ->

		console.log "Done crawling lyrics for artist #{ artist } with genre #{ genre }, lyrics count = ", if lyrics is null then "none" else lyrics.length

		# Send lyrics to server, if the were successfully crawled
		if not AppUtils.isEmptyData( lyrics )
			console.log "[O] Lyrics not empty -> send to server"
			@_sendLyricsToServer( artist, genre, lyrics )
		else 
			console.log "[X] Lyrics empty -> skip"

		# If app is in debug mode, and lyrics were sent to server, stop crawling
		if @sentLyricsToServer and AppData.isDebugMode()
			console.log "[XXX] DEBUG MODE, DONE WITH THIS GENRE"
			@parentContext.allGenreArtistsCrawled( @genre, @genreLyrics )
			return

		# Check if all artists were crawled
		if @currentArtistIndex is @lastArtistIndex

			# If all artists were crawled, notify parent context
			@parentContext.allGenreArtistsCrawled( @genre )
  
		else 

			# If not all artists were crawled, crawl next one
			@currentArtist = @_getNextArtist()

			timeout = AppData.getRequestTimeot()
			context = this
			setTimeout( () -> 
				context._crawlCurrentArtist()
			, timeout
			)
			

	# Move on to the next artist for lyrics crawling
	_getNextArtist: () ->
		return @artists[ ++@currentArtistIndex ]


	# Save lyrics on server
	_sendLyricsToServer: ( artistName, artistGenre, lyrics ) ->

		console.log "Send lyrics to server for artist #{ artistName } with genre #{ artistGenre }, lyrics length = ", lyrics.length

		# Transform lyrics into format needed for saving on server
		content = @_transformLyricsForServer( lyrics )
		content = JSON.stringify content		

		# URL of PHP script for saving lyrics
		phpUrl = AppData.getLyricsWriterUrl()

		# If this is the first time in this session that lyrics are being sent to server
		# Then a new, empty file should be created for storing them
		#shouldCreateEmptyFile = not @sentLyricsToServer

		data = {
			genre         : @genre
			content       : content
			artistName    : artistName
			artistGenre   : artistGenre
			createNewFile : false
		}

		# Remember that sending lyrics to server was done at least once
		@sentLyricsToServer = true

		# Send lyrics to server
		AjaxUtils.sendAjax( 'POST', phpUrl, this, @_sendToServerSuccess, @_sendToServerError, data, null )


	_sendToServerSuccess: ( data, onTheFlyData ) ->
		console.log "[->] Lyrics sent to server"


	_sendToServerError: ( xhr, status ) ->
		console.log "Error while sending lyrics to server"
		console.log xhr 
		console.log status


	# Transform lyrics array to a string with song lyrics separated by a separator
	_transformLyricsForServer: ( lyricsArray ) ->

		if AppUtils.isEmptyData( lyricsArray )
			return ""

		prependSeparator = false
		transformed      = ""

		# Create single string from lyrics array
		# Each two song lyrics are separated with a spearator
		for lyrics in lyricsArray
			transformed  += LYRICS_SEPARATOR if prependSeparator
			transformed  += lyrics 
			prependSeparator = true

		return transformed
