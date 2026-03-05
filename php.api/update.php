<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }

include 'condb.php';

$id = $_POST['id'];
$name = $_POST['name'] ?? '';
$address = $_POST['address'] ?? '';
$province = $_POST['province'] ?? '';
$description = $_POST['description'] ?? '';

$imageName = $_POST['old_image'] ?? 'default.jpg';
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

$sql = "UPDATE places SET name='$name', address='$address', province='$province', description='$description', image='$imageName' WHERE id=$id";
if($conn->query($sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
$conn->close();
?>