import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // [추가] Provider 패키지 임포트
import '../services/vibration_service.dart'; // [추가] 진동 서비스 임포트
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // [삭제] 기존의 로컬 변수 double _vibrationStrength = 50.0; 은 이제 필요 없습니다.
  // 대신 Provider를 통해 전역 변수를 사용합니다.

  @override
  Widget build(BuildContext context) {
    // [수정] Provider를 통해 VibrationService 인스턴스를 가져옵니다.
    // listen: true로 설정되어 있어 값이 바뀌면 화면이 자동으로 다시 그려집니다.
    final vibrationService = Provider.of<VibrationService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내 맞춤 설정', style: AppTextStyles.title),
            const SizedBox(height: 30),

            // [핵심 기능] 진동 세기 조절 카드
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2), // 강조 테두리
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vibration, size: 32, color: AppColors.primary),
                      const SizedBox(width: 10),
                      const Text('진동 세기 조절', style: AppTextStyles.bodyBold),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 아주 두꺼운 슬라이더 (조작 용이성)
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 15.0, // 트랙 두껍게
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0), // 손잡이 크게
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 30.0),
                    ),
                    child: Slider(
                      // [수정] 서비스에 저장된 현재 강도 값을 가져옴
                      value: vibrationService.strength,
                      min: 0,
                      max: 100,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.grey[300],
                      onChanged: (value) {
                        // [수정] 슬라이더를 움직이면 서비스의 값을 업데이트함 (setState 불필요)
                        vibrationService.setStrength(value);
                      },
                      onChangeEnd: (value) {
                        // [수정] 조절이 끝나면 서비스에 정의된 '단발성 진동' 함수 호출
                        // (방금 설정한 그 세기로 울려줍니다)
                        vibrationService.vibrateEvent();
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      // [수정] 텍스트도 서비스의 값을 보여줌
                      '${vibrationService.strength.toInt()}%',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text('일반', style: AppTextStyles.title),
            const SizedBox(height: 10),

            _buildSettingItem(Icons.notifications_active, '알림 설정', '새로운 댓글 알림 받기'),
            _buildSettingItem(Icons.accessibility_new, '화면 설정', '글자 크기 및 고대비 모드'),
            _buildSettingItem(Icons.info_outline, '앱 정보', '버전 1.0.0'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[300]!, width: 1.5), // 테두리 추가
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black87, size: 28),
        ),
        title: Text(title, style: AppTextStyles.bodyBold),
        subtitle: Text(subtitle, style: AppTextStyles.body),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: () {},
      ),
    );
  }
}