import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/edit_memo_service.dart';
import '../../theme/colors.dart';

class EditMemoScreen extends StatefulWidget {
  final int memoId;
  final String initialTitle;
  final String initialContent;
  final String initialCategory;
  final List<String> initialImageUrls;

  const EditMemoScreen({
    Key? key,
    required this.memoId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialCategory,
    required this.initialImageUrls,
  }) : super(key: key);

  @override
  State<EditMemoScreen> createState() => _EditMemoScreenState();
}

class _EditMemoScreenState extends State<EditMemoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  late String _selectedCategory;
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  List<String> _deleteImageUrls = [];

  bool _isSubmitting = false;
  bool _isFormValid = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _selectedCategory = widget.initialCategory;
    _existingImageUrls = List.from(widget.initialImageUrls);

    _titleController.addListener(_validateForm);
    _contentController.addListener(_validateForm);

    _validateForm();
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
        _selectedImages.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  Future<void> _submitMemo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await EditMemoService.updateMemo(
      memoId: widget.memoId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      deleteImageUrls: _deleteImageUrls,
      images: _selectedImages,
    );

    if (success) {
      // pop 할 때 true를 전달
      if (mounted) Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("수정 실패. 다시 시도해주세요.")),
      );
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_existingImageUrls.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _existingImageUrls.map((url) {
              return Stack(
                children: [
                  Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _existingImageUrls.remove(url);
                          _deleteImageUrls.add(url);
                        });
                      },
                      child: Container(
                        color: Colors.black54,
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        if (_selectedImages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.map((file) {
              return Image.file(
                file,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              );
            }).toList(),
          ),
      ],
    );
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
        title: const Text("메모 수정하기"),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: (_isFormValid && !_isSubmitting) ? _submitMemo : null,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.disabled)
                    ? Colors.grey
                    : mainColor,
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
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          // 화면 어디를 눌러도 포커스 해제 → 키보드 내림
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
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
                    DropdownMenuItem(value: "사진명소", child: Text("사진명소")),
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
                _buildImagePreview(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text("이미지 추가"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
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
