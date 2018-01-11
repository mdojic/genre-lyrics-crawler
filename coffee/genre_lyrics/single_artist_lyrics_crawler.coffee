
# Class used for crawling lyrics for a single artist
class @SingleArtistLyricsCrawler

	ARTIST_PAGE_LINK_TEMPLATE = "http://www.darklyrics.com/$first_letter$/$artist_name$.html"
	FIRST_LETTER_SHORTCODE    = "$first_letter$"
	ARTIST_NAME_SHORTCODE     = "$artist_name$"

	constructor: ( @artist, @parentContext, @callbackFunction ) ->

		console.log "&&& created @SingleArtistLyricsCrawler for artist: ", @artist

		@artistName  = @artist.artistName
		@artistGenre = @artist.artistGenre


	crawl: () ->

		console.log "Crawl lyrics for artist: ", @artist

		# Get link for first artist's page 
		link = @_getArtistLink( @artistName )

		# Load artist page
		AjaxUtils.sendAjax( 'GET', link, this, @_artistPageLoaded, @_artistPageLoadingError )


	_artistPageLoaded: ( data, onTheFlyData ) ->
		ArtistLyricsParser.parseArtistLyrics( data, this, @_songLyricsParsed )


	_artistPageLoadingError: ( xhr, status ) ->
		console.log "Artist page not found for artist: #{ @artistName }, move on"
		@callbackFunction.call( @parentContext, @artistName, @artistGenre, null )


	_getFirstLetter: ( artistName ) ->

		if artistName is undefined or artistName is ""
			return ""

		return artistName.charAt(0)


	_removeSpaces: ( artistName ) ->

		nameWithNoSpaces = artistName.replace(/ /g,'')
		return nameWithNoSpaces


	_getArtistLink: ( artistName ) ->

		firstLetter      = @_getFirstLetter( artistName )
		nameWithNoSpaces = @_removeSpaces( artistName )

		link = ARTIST_PAGE_LINK_TEMPLATE
		link = link.replace( FIRST_LETTER_SHORTCODE, firstLetter )
		link = link.replace( ARTIST_NAME_SHORTCODE, nameWithNoSpaces )

		return link.toLowerCase()


	_songLyricsParsed: ( lyrics ) ->

		console.log "% % % _songLyricsParsed, save progress for #{@artistName}"

		AppData.setLastArtist( @artistName )

		progressWriterUrl = AppData.getProgressWriterUrl()
		data = {
			artist : @artistName
		}
		AjaxUtils.sendAjax("POST", progressWriterUrl, this, @_progressWritten, @_progressWritingError, data, lyrics )


	_progressWritten:  (data, onTheFlyData ) ->
		console.log "% % % _progressWritten for #{@artistName}"
		lyrics = onTheFlyData
		@callbackFunction.call( @parentContext, @artistName, @artistGenre, lyrics )


	_progressWritingError: ( errorCode, errorMessage ) ->
		console.log "Error while writing progress"
		console.log errorMessage
		console.log errorCode