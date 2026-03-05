<?php
$host = "localhost";
$user = "root";
$pass = ""; 
$dbname = "tourist_db"; 

// สร้างการเชื่อมต่อ
$conn = new mysqli($host, $user, $pass, $dbname);

// ตั้งค่าให้รองรับภาษาไทย
mysqli_set_charset($conn, "utf8");

// เช็คการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>