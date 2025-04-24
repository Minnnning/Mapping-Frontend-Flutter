import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/memo_list_model.dart';
import '../../services/memo_list_service.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../../theme/colors.dart';
import 'memo_detail_screen.dart';

class MyMemoScreen extends StatefulWidget {
  @override
  _MyMemoScreenState createState() => _MyMemoScreenState();
}

class _MyMemoScreenState extends State<MyMemoScreen> {
  final MemoListService _memoListService = MemoListService();
  late Future<List<MemoList>> _memos;

  @override
  void initState() {
    super.initState();
    _loadUserAndMemos();
  }

  void _loadUserAndMemos() {
    // 유저 정보 로드
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    AuthService().fetchUser(userProvider);
    // 초기 메모 목록 로드
    _memos = _memoListService.fetchMyMemos();
  }

  Future<void> _refreshMemos() async {
    setState(() {
      // future 를 새로 만들어서 FutureBuilder 가 다시 실행되도록
      _memos = _memoListService.fetchMyMemos();
    });
    // 실제로 데이터를 기다리려면:
    await _memos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 메모'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<MemoList>>(
        future: _memos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('메모를 불러오는 중 오류 발생!'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('작성한 메모가 없습니다.'));
          }

          List<MemoList> memos = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshMemos,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // 빈 화면에서도 스크롤 가능
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                return Card(
                  color: boxGray,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(memo.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(memo.content),
                        SizedBox(height: 4),
                        Text('카테고리: ${memo.category}',
                            style: TextStyle(color: Colors.grey)),
                        Text('좋아요: ${memo.likeCnt}, 싫어요: ${memo.hateCnt}',
                            style: TextStyle(color: Colors.grey)),
                        if (memo.images.isNotEmpty)
                          Container(
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: memo.images.map((img) {
                                return Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Image.network(img,
                                      width: 100, fit: BoxFit.cover),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemoDetailScreen(memoId: memo.id),
                        ),
                      ).then((shouldRefresh) {
                        if (shouldRefresh == true) {
                          _refreshMemos();
                        }
                      });
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
