<?php

	if ($_SERVER["REQUEST_METHOD"] == "POST") {

		// Get sent content
		$content = $_POST["content"];
		$genre   = $_POST["genre"];

		// Write file
		$file = "../res/artists/$genre.txt";
		file_put_contents($file, $content);

		echo "= = = wrote genre $genre";
    }

?>