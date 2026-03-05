<?php
// โค้ด 4 บรรทัดนี้คือตัวแก้ Error "Failed to fetch" บนหน้าเว็บครับ
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }

include 'condb.php';

$search = isset($_GET['search']) ? $_GET['search'] : '';
if (!empty($search)) {
    $sql = "SELECT * FROM places WHERE name LIKE '%$search%'";
} else {
    $sql = "SELECT * FROM places ORDER BY id DESC";
}

$result = $conn->query($sql);
$data = array();
if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}
echo json_encode($data);
$conn->close();
?>