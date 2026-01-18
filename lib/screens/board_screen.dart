import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [추가] 내 아이디 확인용
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/board_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boardService = Provider.of<BoardService>(context, listen: false);

    // [현재 내 ID 확인] 삭제 버튼 보여줄지 말지 결정하기 위해 필요
    final String? myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('소통 게시판', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // 글쓰기 버튼
      floatingActionButton: SizedBox(
        width: 120,
        height: 56,
        child: FloatingActionButton.extended(
          onPressed: () => _showWriteDialog(context, boardService),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('글쓰기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        ),
      ),

      // 게시글 목록
      body: StreamBuilder<QuerySnapshot>(
        stream: boardService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          if (!snapshot.data!.docs.isNotEmpty) {
            return const Center(child: Text('첫 글을 남겨보세요!', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // [보안] 글의 주인(uid)이 나(myUid)와 같은지 확인
              bool isMyPost = (data['uid'] == myUid);

              return _buildPostCard(
                title: data['title'] ?? '',
                content: data['content'] ?? '',
                author: data['author'] ?? '익명',
                likes: data['likes'] ?? 0,
                isMyPost: isMyPost,
                onLike: () => boardService.likePost(doc.id, data['likes'] ?? 0),
                onDelete: () => boardService.deletePost(doc.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showWriteDialog(BuildContext context, BoardService service) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final authorController = TextEditingController(text: '익명');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 글 작성'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: '제목')),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: '내용'), maxLines: 3),
              TextField(controller: authorController, decoration: const InputDecoration(labelText: '닉네임')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                // [수정됨] 이제 제목, 내용, 이름만 넘기면 Service가 알아서 ID를 붙여서 보냄
                service.addPost(
                  titleController.text,
                  contentController.text,
                  authorController.text,
                ).then((_) {
                  Navigator.pop(context); // 성공하면 닫기
                }).catchError((e) {
                  // 실패하면(로그인 안됨 등) 에러 메시지
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류: $e")));
                });
              }
            },
            child: const Text('등록', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String title,
    required String content,
    required String author,
    required int likes,
    required bool isMyPost,
    required VoidCallback onLike,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: AppTextStyles.bodyBold.copyWith(fontSize: 20))),
              if (isMyPost) // 내 글일 때만 쓰레기통 보임
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.body),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('작성자: $author', style: const TextStyle(color: Colors.grey)),
              InkWell(
                onTap: onLike,
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 4),
                    Text('$likes', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}