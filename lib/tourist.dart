import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

// ==========================================
// 1. หน้าหลัก (รายการ + ค้นหา + ลบ)
// ==========================================
class TouristListScreen extends StatefulWidget {
  const TouristListScreen({super.key});

  @override
  State<TouristListScreen> createState() => _TouristListScreenState();
}

class _TouristListScreenState extends State<TouristListScreen> {
  List places = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  // แก้ URL ให้ตรงกับโครงสร้างโฟลเดอร์ของคุณ
  final String apiUrl = "http://127.0.0.1/flutter_mid_66703889/php.api";
  final String imageUrl = "http://127.0.0.1/flutter_mid_66703889/php.api/uploads/";

Future<void> fetchPlaces([String query = ""]) async {
    setState(() => isLoading = true);
    
    // ใส่เวลาต่อท้าย URL ป้องกัน Chrome จำข้อมูลเก่า (Cache)
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final url = query.isEmpty 
        ? "$apiUrl/showdata.php?t=$timestamp" 
        : "$apiUrl/showdata.php?search=$query&t=$timestamp";
        
    try {
      final response = await http.get(Uri.parse(url));
      
      // ปริ้นท์ค่าออกมาดูใน Terminal ว่ามันได้อะไรกลับมา!
      print("สถานะการดึงข้อมูล: ${response.statusCode}");
      print("ข้อมูลที่ได้: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          places = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error พังตรงนี้: $e"); // ปริ้นท์บอกถ้าโค้ดพัง
    }
  }

  Future<void> deletePlace(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: const Text("ต้องการลบสถานที่นี้ใช่หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ลบ", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await http.post(Uri.parse("$apiUrl/delete.php"), body: {"id": id});
      fetchPlaces(); 
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แนะนำสถานที่ท่องเที่ยว"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => fetchPlaces(value),
              decoration: InputDecoration(
                hintText: "ค้นหาชื่อสถานที่...",
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : places.isEmpty
              ? const Center(child: Text("ไม่พบข้อมูล"))
              : ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: SizedBox(
                          width: 60,
                          height: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (place['image'] != null && place['image'] != 'default.jpg')
                                ? Image.network("$imageUrl${place['image']}", fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40, color: Colors.grey))
                                : const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        ),
                        title: Text(place['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(place['province'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditTouristScreen(place: place)));
                                fetchPlaces(); 
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deletePlace(place['id'].toString()),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TouristDetailScreen(place: place)));
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditTouristScreen()));
          fetchPlaces(); 
        },
      ),
    );
  }
}

// ==========================================
// 2. หน้าแสดงรายละเอียด 
// ==========================================
class TouristDetailScreen extends StatelessWidget {
  final Map place;
  const TouristDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    // แก้ URL ให้ตรงกับโครงสร้างโฟลเดอร์ของคุณ
    final String imageUrl = "http://127.0.0.1/flutter_mid_66703889/php.api/uploads/";
    
    return Scaffold(
      appBar: AppBar(
        title: Text(place['name'] ?? ''),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: (place['image'] != null && place['image'] != 'default.jpg')
                  ? Image.network("$imageUrl${place['image']}", fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 100, color: Colors.grey)))
                  : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 100, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("จังหวัด: ${place['province'] ?? ''}", style: const TextStyle(fontSize: 16, color: Colors.red)),
                  const SizedBox(height: 10),
                  Text("ที่อยู่: ${place['address'] ?? ''}", style: const TextStyle(fontSize: 16)),
                  const Divider(height: 30, thickness: 1),
                  const Text("รายละเอียด:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(place['description'] ?? 'ไม่มีข้อมูล', style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. หน้าเพิ่ม/แก้ไข (พร้อมอัปโหลดรูป)
// ==========================================
class AddEditTouristScreen extends StatefulWidget {
  final Map? place;
  const AddEditTouristScreen({super.key, this.place});

  @override
  State<AddEditTouristScreen> createState() => _AddEditTouristScreenState();
}

class _AddEditTouristScreenState extends State<AddEditTouristScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController descController = TextEditingController();

  bool isEdit = false;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  
  // แก้ URL ให้ตรงกับโครงสร้างโฟลเดอร์ของคุณ
  final String uploadUrl = "http://127.0.0.1/flutter_mid_66703889/php.api/uploads/";

  @override
  void initState() {
    super.initState();
    if (widget.place != null) {
      isEdit = true;
      nameController.text = widget.place!['name'];
      addressController.text = widget.place!['address'];
      provinceController.text = widget.place!['province'];
      descController.text = widget.place!['description'] ?? '';
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> savePlace() async {
    // แก้ URL ให้ตรงกับโครงสร้างโฟลเดอร์ของคุณ
    final String url = isEdit 
      ? "http://127.0.0.1/flutter_mid_66703889/php.api/update.php" 
      : "http://127.0.0.1/flutter_mid_66703889/php.api/add.php";
      
    var request = http.MultipartRequest('POST', Uri.parse(url));
    
    request.fields['name'] = nameController.text;
    request.fields['address'] = addressController.text;
    request.fields['province'] = provinceController.text;
    request.fields['description'] = descController.text;

    if (isEdit) {
      request.fields['id'] = widget.place!['id'].toString();
      request.fields['old_image'] = widget.place!['image'] ?? 'default.jpg';
    }

    if (_imageFile != null && _imageBytes != null) {
      var multipartFile = http.MultipartFile.fromBytes('image', _imageBytes!, filename: _imageFile!.name);
      request.files.add(multipartFile);
    }

    await request.send();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "แก้ไขสถานที่" : "เพิ่มสถานที่ท่องเที่ยว"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                child: _imageBytes != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                    : (isEdit && widget.place!['image'] != null && widget.place!['image'] != 'default.jpg')
                        ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network("$uploadUrl${widget.place!['image']}", fit: BoxFit.cover))
                        : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 50, color: Colors.grey), Text("คลิกเพื่อเลือกรูปภาพ")]),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "ชื่อสถานที่")),
            TextField(controller: provinceController, decoration: const InputDecoration(labelText: "จังหวัด")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "ที่อยู่")),
            TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: "รายละเอียด")),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: savePlace,
              child: Text(isEdit ? "บันทึกการแก้ไข" : "เพิ่มข้อมูล", style: const TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}