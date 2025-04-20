import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/memo_input_service.dart';
import '../../providers/marker_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';

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

  String _selectedCategory = '기타';
  bool _secret = false;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  bool _isFormValid = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_validateForm);
    _contentController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty;
    setState(() {
      _isFormValid = isValid;
    });
  }

  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

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
      imageFiles: _selectedImages,
    );

    if (response != null) {
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("메모가 성공적으로 생성되었습니다.")),
        );
        // ✅ 마커 새로고침 요청
        Provider.of<MarkerProvider>(context, listen: false).requestRefresh();
        // 두 단계 이전 화면으로 이동
        Navigator.pop(context); // MemoInputScreen2 pop
        Navigator.pop(context); // MemoInputScreen1 pop
      } else {
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
        backgroundColor: Colors.white, // ✅ 앱바 배경색을 흰색으로 설정
        actions: [
          TextButton(
            onPressed: (_isFormValid && !_isSubmitting) ? _submitMemo : null,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey; // 비활성화 시 회색
                  }
                  return mainColor; // 활성화 시
                },
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("저장"),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "제목",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "제목을 입력해주세요."
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: "내용",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "내용을 입력해주세요."
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "카테고리",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "공용 화장실", child: Text("공용 화장실")),
                    DropdownMenuItem(value: "주차장", child: Text("주차장")),
                    DropdownMenuItem(value: "쓰레기통", child: Text("쓰레기통")),
                    DropdownMenuItem(value: "흡연장", child: Text("흡연장")),
                    DropdownMenuItem(value: "기타", child: Text("기타")),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("프라이빗 설정"),
                    Switch(
                      value: _secret,
                      onChanged: (value) {
                        setState(() {
                          _secret = value;
                        });
                      },
                      //activeColor: mainColor, // 스위치 내부 색상
                      activeTrackColor: mainColor, // 스위치 트랙 색상
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedImages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages.map((file) {
                      return Image.file(file,
                          width: 100, height: 100, fit: BoxFit.cover);
                    }).toList(),
                  ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text("이미지 선택 (선택사항)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor, // 버튼 배경색
                    foregroundColor: Colors.white, // 아이콘과 텍스트 색
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
