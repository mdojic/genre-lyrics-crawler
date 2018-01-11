<?php

	if ($_SERVER["REQUEST_METHOD"] == "POST") {

		$file = "../res/progress.txt";

		// Get file content
		$file_content = file_get_contents($file);

		// File content is in the form of:
		// last_genre:genre|last_artist:artist

		$genre_artist_separator = "|";
		$parts = explode($genre_artist_separator, $file_content);

		$genre_part = $parts[0];
		$artist_part = $parts[1];

		// If genre was given, save it
		if ( isset($_POST["genre"]) ) {

			$genre  = $_POST["genre"];

			// Remember the given genre as last one parsed
			$genre_part = "last_genre:$genre";
			
			// Reset artist when saving new genre
			$artist_part = ":";

			$what = "genre";
			$which = $genre;
		}

		// If artist was given, save it
		else if( isset($_POST["artist"]) ){

			$artist = $_POST["artist"];

			// Remember the given artist as the last one parsed
			$artist_part = "last_artist:$artist";

			$what = "artist";
			$which = $artist;
		}

		$file_content = $genre_part."|".$artist_part;

		echo "File content after saving progress: \n";
		echo $file_content."\n";

		// Write file
		file_put_contents($file, $file_content);

		echo "Progress write finished for $what : $which";

    }

?>