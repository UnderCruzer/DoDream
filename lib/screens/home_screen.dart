import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/board_service.dart';
import '../screens/analyze_screen.dart'; // 분석 화면 이동용
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 게시판 데이터 가져오기 위해 서비스 연결
    final boardService = Provider.of<BoardService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white, // 배경색 깔끔하게
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('DoDream', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.grey)
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 인사말
            const Text('안녕하세요,\n오늘도 음악을 느껴보세요!', style: AppTextStyles.title),
            const SizedBox(height: 30),

            // 2. 음악 분석 카드 (메인 기능)
            GestureDetector(
              onTap: () {
                // 카드 누르면 분석 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalyzeScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF00C4B4)], // 민트색 그라데이션
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '주변 음악 분석하기',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '지금 들리는 노래를\n진동으로 변환해 드릴게요.',
                      style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 3. 게시판 미리보기 (여기를 수정했습니다!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('지금 인기있는 이야기', style: AppTextStyles.bodyBold),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),

            // [핵심] StreamBuilder로 실제 게시판 데이터 가져오기
            StreamBuilder<QuerySnapshot>(
              stream: boardService.getPosts(), // 게시판 서비스에서 데이터 받아옴
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('아직 작성된 글이 없어요.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  );
                }

                // 최신글 최대 3개까지만 보여주기 (take(3))
                final recentDocs = docs.take(3).toList();

                return ListView.separated(
                  shrinkWrap: true, // 스크롤 중첩 방지
                  physics: const NeverScrollableScrollPhysics(), // 홈 화면 전체 스크롤을 따름
                  itemCount: recentDocs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = recentDocs[index].data() as Map<String, dynamic>;

                    return _buildMiniPostCard(
                      title: data['title'] ?? '제목 없음',
                      content: data['content'] ?? '내용 없음',
                      likes: data['likes'] ?? 0,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 홈 화면용 미니 게시글 카드 디자인
  Widget _buildMiniPostCard({
    required String title,
    required String content,
    required int likes,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!), // 연한 테두리
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
              const SizedBox(width: 4),
              Text(
                '$likes',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          )
        ],
      ),
    );
  }
}