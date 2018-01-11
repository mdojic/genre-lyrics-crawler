class @SingeGenreArtistsCrawler

	GENRE_URL_TEMPLATE   = "https://www.metal-archives.com/browse/ajax-genre/g/${genre}/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=${start}&iDisplayLength=500&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false&_=1497809147851"
	GENRE_SHORTCODE      = "${genre}"
	START_SHORTCODE      = "${start}"

	FIRST_LOAD_TIMEOUT = 2000
	DEFAULT_TIMEOUT    = 750

	DEBUG_MODE = false

	constructor: ( @genre, @parentContext ) ->
   
		console.log "Started crawler for genre #{ genre }..."
		@genreArtists  = []

		@maxPages    = 3
		@currentPage = 1


	crawl: () ->
		@_loadByGenre( @genre )


	_loadByGenre: ( genre ) ->

		isFirstLoad  = @currentPage is 1
		timeoutValue = if isFirstLoad then FIRST_LOAD_TIMEOUT else DEFAULT_TIMEOUT

		if DEBUG_MODE
			setMaxPages = false 
		else 
			setMaxPages = isFirstLoad

		if @currentPage is @maxPages
			self = this
			setTimeout( () ->
				self._saveGenreArtists( genre )
			, @maxPages * DEFAULT_TIMEOUT
			)
			return

		searchUrl = @_createSearchUrl( genre, @currentPage++ )

		onTheFlyData = {
			genre       : genre 
			setMaxPages : setMaxPages
		}

		AjaxUtils.sendAjax( 'GET', searchUrl, this, @_searchSuccess, @_searchError, null, onTheFlyData )

		self = this
		setTimeout( () ->
			self._loadByGenre( genre )
		, timeoutValue		
		)


	_createSearchUrl: ( genre, page ) ->

		start = (page - 1) * 500
		
		url = GENRE_URL_TEMPLATE
		url = url.replace( GENRE_SHORTCODE, genre )
		url = url.replace( START_SHORTCODE, start )

		return url


	_searchSuccess: ( data, onTheFlyData ) ->

		responseJson = data

		genre       = onTheFlyData.genre 
		setMaxPages = onTheFlyData.setMaxPages

		artists = responseJson.aaData
		if setMaxPages
			totalResults = responseJson.iTotalRecords
			@maxPages    = Math.ceil(totalResults / 500) + 1
			console.log "--- total results = ", totalResults
			console.log "--- max pages = ", @maxPages

		@genreArtists = @genreArtists.concat( artists )


	_searchError: ( xhr, status ) ->
		console.log "Search error"
		console.log xhr 
		console.log status


	_saveGenreArtists: ( genre ) ->

		console.log "Sending genre #{ genre } to server..."

		artistDescriptions = []
		for artistInfo in @genreArtists 
			artistName  = @_getArtistName( artistInfo )
			artistGenre = @_getArtistGenre( artistInfo )

			artistDescription = {
				artistName  : artistName.trim()
				artistGenre : artistGenre.trim()
			}

			artistDescriptions.push( artistDescription )

		@_sendToServer( genre, artistDescriptions )


	_getArtistName: ( artistInfo ) ->

		artistLink = artistInfo[0]

		artistNameStart = artistLink.indexOf(">") + 1
		artistNameEnd   = artistLink.indexOf("</a", artistNameStart)
		artistName      = artistLink.substring( artistNameStart, artistNameEnd )

		return artistName


	_getArtistGenre: ( artistInfo ) ->
		return artistInfo[2]


	_sendToServer: ( genre, content ) ->

		content = JSON.stringify( content )

		phpUrl = "php/genre_artist_writer.php"

		data = {
			genre   : genre 
			content : content
		}

		AjaxUtils.sendAjax( 'POST', phpUrl, this, @_sendToServerSuccess, @_sendToServerError, data, null )


	_sendToServerSuccess: ( data ) ->
		console.log "Info sent to server, received data: \n", data
		@parentContext.genreCrawlingDone( @genre )


	_sendToServerError: ( xhr, status ) ->
		console.log "Error while sending content to server"
		console.log xhr 
		console.log status


$ ->
	console.log "@SingeGenreArtistsCrawler loaded"