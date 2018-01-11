<?php
		
	if ($_SERVER["REQUEST_METHOD"] == "POST") {

		echo "FILTER PLS PHP";

		$genres = ["black", "thrash", "death", "doom"];
		
		$unwanted_subgenres = new stdClass();
		$unwanted_subgenres->black  = ["death", "doom", "thrash", "electronic", "heavy", "speed", "grind", "melodic", "rock", "punk", "viking", "folk", "avant"];
		$unwanted_subgenres->thrash = ["death", "doom", "black", "electronic", "heavy", "grind", "melodic", "rock", "viking", "folk", "avant"];
		$unwanted_subgenres->death  = ["thrash", "doom", "black", "electronic", "heavy", "speed", "grind", "melodic", "rock", "punk", "viking", "folk", "avant"];
		$unwanted_subgenres->doom   = ["thrash", "death", "black", "electronic", "heavy", "speed", "grind", "melodic", "rock", "punk", "viking", "folk", "avant"];


		foreach ($genres as $genre) {

			$file_name = "$genre.txt";
			$file_content = file_get_contents("../res/artists/$file_name");

			$file_content = str_replace("'", "\'", $file_content);
			$file_content = str_replace("\"", "'", $file_content);

			$artists_json = json_decode($file_content);

			$filtered = [];
			foreach ($artists_json as $artist) {

				$artist_name = $artist->artistName;
				$artist_genre = $artist->artistGenre;
				$artist_genre = strtolower($artist_genre);

				$keep = true;
				foreach ($unwanted_subgenres as $unwanted_subgenre) {
					if (strpos($artist_genre, $unwanted_subgenre) !== false) {
						$keep = false;
						break;
					}
				}

				if ($keep) {
					$filtered.push($artists_json);
				}

			}

			$filtered_json = json_encode($filtered);

			$filtered_file = "../res/artists_filtered/$genre.txt";
			file_put_contents($filtered_file, $filtered_json);
		}

		echo "Filter success";
    } 
?>