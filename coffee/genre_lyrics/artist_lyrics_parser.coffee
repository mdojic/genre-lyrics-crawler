class @ArtistLyricsParser

	ALBUM_CONTAINER_ELEMENT = "div"
	ALBUM_CONTAINER_CLASS   = "album"

	@parseArtistLyrics: ( artistLyricsPage, @callbackContext, @parseSuccessFunction ) ->

		# Container element for artist page
		@artistLyricsPage = $(artistLyricsPage)

		# Find all album elements on artist's page
		@albumElements    = @artistLyricsPage.find( "#{ ALBUM_CONTAINER_ELEMENT }.#{ ALBUM_CONTAINER_CLASS }" )

		console.log "=== Number of albums: ", @albumElements.length

		if @albumElements.length is 0
			@parseSuccessFunction.call( @callbackContext, [])
			return

		# For remembering which album is currently being parsed
		@currentAlbumIndex   = 0
		@currentAlbumElement = @albumElements[ @currentAlbumIndex ]
		
		# For checking if all albums were parsed
		@lastAlbumIndex		 = @albumElements.length - 1

		# For keeping all lyrics from this artistLyrics
		@artistAlbumLyrics = []

		# Parse current album
		AlbumLyricsParser.parseAlbumLyrics( @currentAlbumElement, this, @albumElementParsed )


	@albumElementParsed: ( lyrics ) ->

		@artistAlbumLyrics = @artistAlbumLyrics.concat( lyrics )

		if @currentAlbumIndex is @lastAlbumIndex
			console.log "[<-] Parsed last album"
			@parseSuccessFunction.call( @callbackContext, @artistAlbumLyrics )
		else 
			console.log "[-] Not last album yet, parse next one"
			@currentAlbumElement = @_getNextAlbumElement()

			context = this 
			timeout = AppData.getRequestTimeot()
			setTimeout( () ->
				AlbumLyricsParser.parseAlbumLyrics( context.currentAlbumElement, context, context.albumElementParsed )
			, timeout
			)


	# Move on to the next album to parse
	@_getNextAlbumElement: () ->
		return @albumElements[ ++@currentAlbumIndex ]


# Inner class for parsing lyrics from a single album
class AlbumLyricsParser

	# String to prepend to relative URLs and get absolute url
	ROOT_URL = "http://www.darklyrics.com"

	# Selectors for finding song urls in album section on artist pag
	SONG_ELEMENT                  = "a"
	SONG_ELEMENT_URL_ATTRIBUTE    = "href"

	# Selectors for finding song lyrics containers on album pages
	SONG_LYRICS_CONTAINER_ELEMENT = "div"
	SONG_LYRICS_CONTAINER_CLASS   = "lyrics"
	SINGLE_SONG_LYRICS_SEPARATOR  = "<h3>"


	@parseAlbumLyrics: ( @albumElement, @parentContext, @callbackFunction ) ->

		console.log "Parse album lyrics for album element: ", @albumElement

		albumElement = $( @albumElement )

		# Find all song elements from this album element
		@songElements = albumElement.find( "#{ SONG_ELEMENT }" )

		# Get first song
		firstSong = @songElements.get(0)
		firstSong = $(firstSong)

		# Album elements contain song lyrics URLs
		# Every song lyric URL leads to the same page, with a different anchor (hashtag)
		# Therefore, open the URL of the first song, and parse all song lyrics from there
		url = firstSong.attr( SONG_ELEMENT_URL_ATTRIBUTE )
		url = @_getAlbumLyricsAbsoluteUrl( url )
			
		urlIsValid = @_isUrlDomainValid( url )

		if urlIsValid
			# Load page containing all song lyrics for this album
			AjaxUtils.sendAjax( 'GET', url, this, @_albumSongsPageLoaded, @_albumSongsPageLoadingError )

		else 

			@callbackFunction.call( @parentContext, [] )


	# Get absolute URL for album
	@_getAlbumLyricsAbsoluteUrl: ( relativeUrl ) ->

		if AppUtils.isEmptyData( relativeUrl )
			return ""

		absoluteUrl = relativeUrl.replace("..", ROOT_URL)
		return absoluteUrl


	# Success function for loading album songs page
	@_albumSongsPageLoaded: ( data, onTheFlyData ) ->

		console.log "--- Loaded page with album lyrics"

		albumSongsPage      = $(data) 
		songLyricsContainer = albumSongsPage.find( "#{ SONG_LYRICS_CONTAINER_ELEMENT }.#{ SONG_LYRICS_CONTAINER_CLASS }" )
		songLyricsContent   = songLyricsContainer.html()
		
		# if AppUtils.isEmptyData( songLyricsContent )
		# 	# If there are no song lyrics, save an empty array
		# 	songsLyrics = []
		# else 
		# 	# Split page content into separate song lyrics
		# 	songsLyrics = songLyricsContent.split( SINGLE_SONG_LYRICS_SEPARATOR )

		# # Parse all song lyrics
		# albumLyrics = []
		# for songLyrics in songsLyrics
		# 	parsedLyrics = SongLyricsParser.parseSongLyrics( songLyrics )
		# 	albumLyrics.push( parsedLyrics )

		# console.log "Album has #{ albumLyrics.length } song lyrics"

		# Notify caller that the album lyrics were parsed
		# @callbackFunction.call( @parentContext, albumLyrics )
		@callbackFunction.call( @parentContext, songLyricsContent )


	@_albumSongsPageLoadingError: ( xhr, status ) ->
		console.log "Error while loading album songs page"
		console.log xhr
		console.log status
		@callbackFunction.call( @parentContext, [] )


	@_isUrlDomainValid: ( url ) ->
		return (not AppUtils.isEmptyData(url)) and (url.indexOf("darklyrics.com") > -1)


# Inner class for parsing lyrics of a single song
class SongLyricsParser

	# Parse lyrics of a song (remove html tags)
	@parseSongLyrics: ( songLyrics ) ->

		songLyrics = songLyrics.replace(/<(?:.|\n)*?>/gm, '');
		return songLyrics
