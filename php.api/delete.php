<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }

include 'condb.php';

if(isset($_POST['id'])) {
    $id = $_POST['id'];
    // (ทางเลือก) ถ้าต้องการลบไฟล์รูปออกจากโฟลเดอร์ uploads ด้วยให้ Query หารูปเก่าก่อนลบ
    $sql = "DELETE FROM places WHERE id = $id";
    if($conn->query($sql)) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error"]);
    }
}
$conn->close();
?>