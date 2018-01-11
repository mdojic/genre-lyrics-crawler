class @GenreProcessingUtils

	UNWANTED_SUBGENRES = {
		death  : ["thrash", "doom", "black", "electronic", "heavy", "speed", "grind", "melodic", "rock", "punk", "viking", "folk", "avant", "gothic", "industrial", "roll"]
		black  : ["death", "doom", "thrash", "electronic", "heavy", "speed", "grind", "melodic", "rock", "punk", "viking", "folk", "avant", "gothic", "industrial", "roll"]
		doom   : ["thrash", "death", "black", "electronic", "heavy", "speed", "grind", "melodic", "rock", "punk", "viking", "folk", "avant", "gothic", "industrial", "roll"]
		thrash : ["death", "doom", "black", "electronic", "heavy", "grind", "melodic", "rock", "viking", "folk", "avant", "gothic", "industrial", "roll"]
	}
 
	@filterGenreArtists: ( artists, genre ) ->

		console.log "*** *** filterGenreArtists for genre: ", genre
		unwantedSubgenres = UNWANTED_SUBGENRES[genre]

		if unwantedSubgenres is undefined 
			console.log "No unwanted subgenres for genre " + genre
			return artists

		console.log "*** unwantedSubgenres: ", unwantedSubgenres

		filteredArtists   = []

		for artist in artists 

			artistGenre = artist.artistGenre.toLowerCase() 
			artistHasUnwantedSubgenre = false

			for unwantedSubgenre in unwantedSubgenres
				artistHasUnwantedSubgenre = artistGenre.indexOf(unwantedSubgenre) > -1
				break if artistHasUnwantedSubgenre

			filteredArtists.push( artist ) if not artistHasUnwantedSubgenre

		return filteredArtists
