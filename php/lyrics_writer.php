<?php

	if ($_SERVER["REQUEST_METHOD"] == "POST") {

		// Get sent data
		$content      = $_POST["content"];
		$genre        = $_POST["genre"];
		$artist_name  = $_POST["artistName"];
		$artist_genre = $_POST["artistGenre"];
		$fresh        = $_POST["createNewFile"];   

		// Get path to genre lyrics file
		$file = "../res/lyrics/$genre.txt";

		// Determine whether to create empty file
		if ($fresh == "true" && file_exists($file)) {
			unlink($file);
		}

		// If this is the first request to write to the file
		if (!file_exists($file)) {
			// Write empty array to new file
			file_put_contents($file, "[]", FILE_APPEND);

			echo "NEW FILE \n\n";

			// The first artist JSON won't be preceded by a comma
			$prepend_coma = false;
		} else {

			echo "NOT NEW FILE \n\n";

			// All artist JSONs except the first one are preceded by a comma
			$prepend_coma = true;
		}

		// Get old file content and remove the closed array bracket from it
		$file_old_content = file_get_contents($file);
		$file_old_content = str_replace("]", "", $file_old_content);

		// Create object for this artist's JSON
		$artistObj = new stdClass();

		// Write this artist's data and create a JSON from it
		$artistObj->artistName  = $artist_name;
		$artistObj->artistGenre = $artist_genre;
		$artistObj->albumLyrics = $content;

		$artistJSON = json_encode($artistObj);

		// Prepend artist info with comma if needed
		if ($prepend_coma) {
			$artistJSON = ",".$artistJSON;
		}

		// Append artist JSON to file content and close the array bracket
		$file_new_content = $file_old_content.$artistJSON."]";

		// Write file
		file_put_contents($file, $file_new_content);

		echo "Wrote lyrics for genre $genre";
    }

?>