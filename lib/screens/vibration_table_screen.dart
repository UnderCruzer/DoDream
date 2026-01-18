import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class VibrationTableScreen extends StatelessWidget {
  const VibrationTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 음계 데이터 (음이름, 진동 패턴 길이)
    final List<Map<String, dynamic>> notes = [
      {'note': '도', 'sub': 'C', 'pattern': [0, 500]}, // 웅~ (길게)
      {'note': '레', 'sub': 'D', 'pattern': [0, 100, 100, 100]}, // 웅, 웅
      {'note': '미', 'sub': 'E', 'pattern': [0, 100, 50, 100, 50, 100]}, // 웅,웅,웅 (빠르게)
      {'note': '파', 'sub': 'F', 'pattern': [0, 200, 200, 200]},
      {'note': '솔', 'sub': 'G', 'pattern': [0, 50, 50, 50, 50, 500]},
      {'note': '라', 'sub': 'A', 'pattern': [0, 400, 100, 100]},
      {'note': '시', 'sub': 'B', 'pattern': [0, 100, 100, 100, 100, 100]},
      {'note': '도↑', 'sub': 'C5', 'pattern': [0, 1000]}, // 아주 길게
    ];

    return Scaffold(
      backgroundColor: Colors.white, // 깔끔한 흰 배경
      appBar: AppBar(
        title: const Text('진동 패턴 익히기', style: AppTextStyles.title),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '버튼을 눌러 각 음계의\n진동 느낌을 기억해보세요.',
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 2개씩 크게
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3, // 납작하지 않고 큼직하게
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return _buildNoteCard(notes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          // [핵심] 햅틱 피드백 발생
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(pattern: note['pattern']);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            // 고대비: 굵은 테두리와 그림자
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(4, 4), // 뚜렷한 그림자
                blurRadius: 0, // 흐리지 않고 선명하게 (레트로/고대비 스타일)
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                note['note'],
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary
                ),
              ),
              Text(
                note['sub'],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54
                ),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.vibration, color: AppColors.secondary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}