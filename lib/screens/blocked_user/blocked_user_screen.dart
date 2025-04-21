import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_block_service.dart';
import '../../providers/marker_provider.dart';

class BlockedUserScreen extends StatefulWidget {
  const BlockedUserScreen({Key? key}) : super(key: key);

  @override
  _BlockedUserScreenState createState() => _BlockedUserScreenState();
}

class _BlockedUserScreenState extends State<BlockedUserScreen> {
  late Future<List<BlockedUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = UserBlockService.fetchBlockedUsers();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = UserBlockService.fetchBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차단된 사용자'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<BlockedUser>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('로드 실패: ${snap.error}'));
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('차단된 사용자가 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final user = list[i];
                return ListTile(
                  leading: user.profileImageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user.profileImageUrl!),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.nickname),
                  trailing: TextButton(
                    child: const Text('차단 해제'),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('차단 해제'),
                          content: Text('${user.nickname}님의 차단을 해제하시겠습니까?'),
                          actions: [
                            TextButton(
                              child: const Text('취소'),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: const Text('해제'),
                              onPressed: () async {
                                final success =
                                    await UserBlockService.unblockUser(
                                        user.userId);
                                Navigator.pop(context, success);
                              },
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('차단이 해제되었습니다.')),
                        );
                        // 필요시 마커 새로고침
                        Provider.of<MarkerProvider>(context, listen: false)
                            .requestRefresh();
                        _refresh();
                      } else if (ok == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('차단 해제에 실패했습니다.')),
                        );
                      }
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
