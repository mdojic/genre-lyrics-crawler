<?php
		
	if ($_SERVER["REQUEST_METHOD"] == "GET") {

		$genre = $_GET["genre"];
		$read_all = $_GET["readAll"];

		if ($read_all) {
			$file_path = "../res/artists";
		} else {
			$file_path = "../res/artists_filtered";
		}

		$file_name = "$genre.txt";

		$file_content = file_get_contents("$file_path/$file_name");

		echo $file_content;
    } 
?>