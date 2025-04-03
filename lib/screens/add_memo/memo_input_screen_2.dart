import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/memo_input_service.dart'; // 새로 생성한 서비스 파일 임포트

class MemoInputScreen2 extends StatefulWidget {
  final double markerLatitude;
  final double markerLongitude;
  final double currentLatitude;
  final double currentLongitude;

  const MemoInputScreen2({
    Key? key,
    required this.markerLatitude,
    required this.markerLongitude,
    required this.currentLatitude,
    required this.currentLongitude,
  }) : super(key: key);

  @override
  _MemoInputScreen2State createState() => _MemoInputScreen2State();
}

class _MemoInputScreen2State extends State<MemoInputScreen2> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = '기타'; // 기본값: 기타
  bool _secret = false; // 기본값: 공개 (false)
  File? _selectedImage;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  // 이미지 선택 함수 (갤러리에서 선택)
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 폼 전송 함수 (서비스 호출)
  Future<void> _submitMemo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final response = await MemoInputService.submitMemo(
      title: _titleController.text,
      content: _contentController.text,
      lat: widget.markerLatitude,
      lng: widget.markerLongitude,
      category: _selectedCategory,
      secret: _secret,
      currentLat: widget.currentLatitude,
      currentLng: widget.currentLongitude,
      image: _selectedImage,
    );

    if (response != null) {
      if (response.statusCode == 201) {
        // 성공 시 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("메모가 성공적으로 생성되었습니다.")),
        );
        Navigator.pop(context);
      } else {
        // 실패 시 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("생성 실패: ${response.statusCode}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("메모 생성 중 오류 발생.")),
      );
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("메모 작성하기"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 제목 입력
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "제목",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "제목을 입력해주세요." : null,
                ),
                const SizedBox(height: 16),
                // 내용 입력
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: "내용",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value == null || value.isEmpty ? "내용을 입력해주세요." : null,
                ),
                const SizedBox(height: 16),
                // 카테고리 선택 (드롭다운)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "카테고리",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "공용 화장실",
                      child: Text("공용 화장실"),
                    ),
                    DropdownMenuItem(
                      value: "주차장",
                      child: Text("주차장"),
                    ),
                    DropdownMenuItem(
                      value: "쓰레기통",
                      child: Text("쓰레기통"),
                    ),
                    DropdownMenuItem(
                      value: "기타",
                      child: Text("기타"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // 비공개 스위치
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("비공개"),
                    Switch(
                      value: _secret,
                      onChanged: (value) {
                        setState(() {
                          _secret = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 이미지 선택 및 미리보기
                if (_selectedImage != null)
                  Column(
                    children: [
                      Image.file(
                        _selectedImage!,
                        height: 150,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("이미지 선택 (선택사항)"),
                ),
                const SizedBox(height: 24),
                // 전송 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitMemo,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("메모 전송"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
