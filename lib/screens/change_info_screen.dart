import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/change_info_service.dart';
import '../theme/colors.dart';

class ChangeInfoScreen extends StatefulWidget {
  const ChangeInfoScreen({super.key});

  @override
  State<ChangeInfoScreen> createState() => _ChangeInfoScreenState();
}

class _ChangeInfoScreenState extends State<ChangeInfoScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  File? _selectedImage;
  bool _isNicknameValid = false;

  void _validateNickname(String value) {
    final trimmed = value.trim();
    setState(() {
      _isNicknameValid = trimmed.isNotEmpty && trimmed.length > 2;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitNickname() async {
    final success =
        await ChangeInfoService.updateNickname(_nicknameController.text.trim());
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("닉네임이 변경되었습니다.")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("닉네임 변경 실패")));
    }
  }

  Future<void> _submitProfileImage() async {
    if (_selectedImage == null) return;

    final success = await ChangeInfoService.updateProfileImage(_selectedImage!);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("프로필 이미지가 변경되었습니다.")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("프로필 이미지 변경 실패")));
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text("프로필 정보 변경"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 닉네임 변경 카드
            Card(
              color: boxGray,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("닉네임 변경",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: "새 닉네임",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _validateNickname,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isNicknameValid ? _submitNickname : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "닉네임 변경",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 프로필 이미지 변경 카드
            Card(
              color: boxGray,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("프로필 이미지 변경",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!,
                                width: 100, height: 100, fit: BoxFit.cover)
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.person,
                                    size: 50, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickImage,
                            child: const Text("이미지 선택"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedImage != null
                                ? _submitProfileImage
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: const Text("이미지 변경"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
