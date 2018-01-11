<?php

	if ($_SERVER["REQUEST_METHOD"] == "POST") {

		// Get sent content
		$data = $_POST["data"];

		foreach ($data as $genreData) {
			$genre = $data->genre;
			$content = $data->content;

			// Write file
			$file = "../res/artists_filtered/$genre.txt";
			file_put_contents($file, $content);

			echo "= = = wrote filtered genre $genre";
		}
		
    }

?>