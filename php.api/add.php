<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }

include 'condb.php';

$name = $_POST['name'] ?? '';
$address = $_POST['address'] ?? '';
$province = $_POST['province'] ?? '';
$description = $_POST['description'] ?? '';

$imageName = 'default.jpg'; 
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = 'uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }
    $imageName = time() . '_' . basename($_FILES['image']['name']);
    if (move_uploaded_file($_FILES['image']['tmp_name'], $uploadDir . $imageName)) {
        // Success
    } else {
        error_log("Failed to move uploaded file: " . $_FILES['image']['tmp_name'] . " to " . $uploadDir . $imageName);
    }
}

$sql = "INSERT INTO places (name, address, province, description, image) VALUES ('$name', '$address', '$province', '$description', '$imageName')";
if($conn->query($sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
$conn->close();
?>