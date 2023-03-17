<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-type: text/plain; charset=utf8');
    include 'config.php';

    // Generate a random string for the file/folder name
    function short_unique_name($dir, $ext = "")
    {
        $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        $name = "";

        // Add random characters until the name is unique
        while (true) {
            $index = rand(0, strlen($characters) - 1);
            $name .= $characters[$index];
            $path = $dir . "/" . $name . $ext;
            if (!file_exists($path)) {
                return [
                    "name" => $name . $ext,
                    "path" => $path,
                ];
            }
        }
    }

    // Function to validate a URL
    function validate_url($url)
    {
        $path = parse_url($url, PHP_URL_PATH);
        $encoded_path = array_map('urlencode', explode('/', $path));
        $url = str_replace($path, implode('/', $encoded_path), $url);

        return filter_var($url, FILTER_VALIDATE_URL) ? true : false;
    }

    if (isset($_FILES["file"])) {
        // If the user has uploaded a file, process it
        // Get the file extension (from the user)
        $path_parts = pathinfo($_FILES["file"]["name"]);
        $file_ext = isset($path_parts["extension"]) ? "." . $path_parts["extension"] : ".bin";

        // Set the file name
        $file_names = short_unique_name($config_array["file_dir"], $file_ext);

        // Move the file if safe
        if (move_uploaded_file($_FILES['file']['tmp_name'], $file_names["path"])) {
            echo $_SERVER['HTTP_HOST'] . "/" . $file_names["path"];
        } else {
            http_response_code(422);
            echo "Possible file upload attack!";
            exit;
        }
    } elseif (isset($_POST["shorten"])) {
        // If the user has entered a URL, attempt to shorten it
        // Validate the URL
        if (!validate_url($_POST["shorten"])) {
            http_response_code(400);
            echo "Invalid URL!";
            exit;
        }

        // Set the folder name
        $folder_names = short_unique_name($config_array["redr_dir"]);

        // Create the folder (parents really should exist)
        mkdir($folder_names["path"], 0777, false);

        // Set .htaccess file contents
        $htaccess = "RewriteEngine on\nRewriteRule ^(.*)$ " . $_POST['shorten'] . " [R=307,L]";

        // Create the .htaccess file
        file_put_contents($folder_names["path"] . "/.htaccess", $htaccess);

        // Return the shortened URL
        echo $_SERVER['HTTP_HOST'] . "/" . $folder_names["path"] . "/";
    } else {
        http_response_code(400);
        echo "No file or URL provided!";
        exit;
    }

} else {
    include 'includes/index.html';
}
