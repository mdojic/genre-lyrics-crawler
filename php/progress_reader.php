<?php 
	
	if ($_SERVER["REQUEST_METHOD"] == "GET") {

		$file = "../res/progress.txt";

		# File content is in the form of:
		# last_genre:genre|last_artist:artist
		$file_content = file_get_contents($file);

		# Get genre and artist parts of file content
		$genre_artist_separator = "|";
		$parts = explode($genre_artist_separator, $file_content);
		$genre_part = $parts[0];
		$artist_part = $parts[1];

		# Split genre and artist parts to get their values
		$part_separator = ":";
		$genre_parts = explode($part_separator, $genre_part);
		$artist_parts = explode($part_separator, $artist_part);

		# Get values of last genre and last artist
		$genre = $genre_parts[1];
		$artist = $artist_parts[1];

		# Create object for progress
		$progress = new stdClass();
		$progress->genre = $genre; 
		$progress->artist = $artist;

		# Return JSON
		echo json_encode($progress);
	}

?>