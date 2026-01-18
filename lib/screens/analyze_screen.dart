import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:provider/provider.dart'; // [추가] Provider 패키지
import 'dart:async';
import '../services/vibration_service.dart'; // [추가] 진동 서비스
import '../utils/app_colors.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  late final RecorderController recorderController;
  Timer? _vibrationTimer;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initialiseControllers();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  // 분석 시작 (녹음 + 진동 서비스 호출)
  void _startAnalysis(VibrationService vibrationService) async {
    final hasPermission = await recorderController.checkPermission();
    if (!hasPermission) return;

    await recorderController.record();

    setState(() {
      _isRecording = true;
    });

    // [핵심 로직 변경]
    // 기존: 직접 진동 명령 -> 변경: Service에게 "음악 진동 울려줘" 요청
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isRecording) {
        // 현재 마이크로 들어오는 소리 크기 (가상 데이터)
        // 0.0(조용함) ~ 1.0(시끄러움) 사이의 값
        // 실제로는 오디오 버퍼를 분석해야 하지만, MVP에서는 랜덤 변동으로 느낌을 구현합니다.
        double currentVolume = (DateTime.now().millisecond % 100) / 100.0;

        // [연결] 서비스가 사용자 설정값(%)을 반영해서 알아서 진동을 울려줍니다.
        vibrationService.vibrateOnMusic(currentVolume);
      }
    });
  }

  // 분석 중지
  void _stopAnalysis() async {
    await recorderController.stop();
    _vibrationTimer?.cancel();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    recorderController.dispose();
    _vibrationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [추가] Provider를 통해 VibrationService 가져오기
    // (listen: false는 여기서 값이 바뀔 때 화면을 다시 그릴 필요는 없어서입니다)
    final vibrationService = Provider.of<VibrationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('음악 분석'),
      ),
      body: Column(
        children: [
          // 1. 상단 상태 메시지
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRecording ? '주변 소리를 듣고 있어요' : '버튼을 눌러 분석을 시작하세요',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isRecording ? '설정된 세기로 진동이 울립니다' : '마이크 권한이 필요합니다',
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textGray
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 실시간 파형 시각화
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AudioWaveforms(
                enableGesture: false,
                size: Size(MediaQuery.of(context).size.width, 200),
                recorderController: recorderController,
                waveStyle: const WaveStyle(
                  waveColor: AppColors.primary,
                  extendWaveform: true,
                  showMiddleLine: false,
                  spacing: 8.0,
                ),
              ),
            ),
          ),

          // 3. 제어 버튼
          Expanded(
            flex: 2,
            child: Center(
              child: GestureDetector(
                // [변경] 버튼 누를 때 vibrationService를 넘겨줌
                onTap: _isRecording ? _stopAnalysis : () => _startAnalysis(vibrationService),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.redAccent : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.redAccent : AppColors.primary).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}