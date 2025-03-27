import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/memo_list_model.dart';
import '../../services/memo_list_service.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';

class CommentedMemoScreen extends StatefulWidget {
  @override
  _CommentedMemoScreenState createState() => _CommentedMemoScreenState();
}

class _CommentedMemoScreenState extends State<CommentedMemoScreen> {
  final MemoListService _memoListService = MemoListService();
  late Future<List<MemoList>> _memos;

  @override
  void initState() {
    super.initState();
    // 유저 정보를 가져오기 위해 AuthService의 fetchUser 호출
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    AuthService().fetchUser(userProvider).then((user) {
      if (user != null) {
        print('유저 정보: ${user.nickname}'); // 유저 정보 출력
      } else {
        print('유저 정보 가져오기 실패');
      }
    });

    // 내 메모 데이터 가져오기
    _memos = _memoListService.fetchCommentedMemos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 메모'),
      ),
      body: FutureBuilder<List<MemoList>>(
        future: _memos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('메모를 불러오는 중 오류 발생!'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('메모가 없습니다.'));
          }

          List<MemoList> memos = snapshot.data!;

          return ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              MemoList memo = memos[index];

              return Card(
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
