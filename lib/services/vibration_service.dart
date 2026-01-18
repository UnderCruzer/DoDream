import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class VibrationService with ChangeNotifier {
  // 기본 진동 세기 (0 ~ 100)
  double _userStrength = 50.0;

  double get strength => _userStrength;

  // 1. 세기 조절 (설정 화면에서 호출)
  void setStrength(double val) {
    _userStrength = val;
    notifyListeners(); // 앱 전체에 "설정 바뀌었다!"고 알림
  }

  // 2. 단발성 진동 (버튼 클릭, 알림 등)
  Future<void> vibrateEvent() async {
    if (await Vibration.hasVibrator() ?? false) {
      // 사용자가 설정한 세기(%)를 1~255 범위로 변환
      int amplitude = (_userStrength * 2.55).toInt();
      if (amplitude < 10) amplitude = 10; // 너무 약하면 안 느껴지므로 최소값 보장

      Vibration.vibrate(duration: 100, amplitude: amplitude);
    }
  }

  // 3. 패턴 진동 (음악 학습용: 쿵-짝-쿵-짝)
  Future<void> vibratePattern(List<int> pattern) async {
    if (await Vibration.hasVibrator() ?? false) {
      // 패턴 진동은 amplitude 조절이 제한적일 수 있으나,
      // 최신 API는 intensities 파라미터를 지원하기도 함.
      // 여기서는 기본 패턴 기능을 사용합니다.
      Vibration.vibrate(pattern: pattern);
    }
  }

  // 4. [핵심] 음악 분석용 실시간 진동 (소리 크기에 비례)
  // currentVolume: 현재 마이크로 들어오는 소리 크기 (0.0 ~ 1.0)
  Future<void> vibrateOnMusic(double currentVolume) async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;

      int finalAmplitude = (currentVolume * _userStrength * 2.55).toInt();
      print("진동 발생 소리크기: $currentVolume, 진동세기: $finalAmplitude");
      if (hasVibrator) {
        if (finalAmplitude > 20) {
          if (finalAmplitude > 255) finalAmplitude = 255;
          Vibration.vibrate(duration: 80, amplitude: finalAmplitude);
        }
        } else {
        print("진동발생 안됨");
      }

      // 잡음(너무 작은 소리)은 진동 안 울리게 처리 (Threshold)
      if (finalAmplitude > 20) {
        if (finalAmplitude > 255) finalAmplitude = 255;
        Vibration.vibrate(duration: 80, amplitude: finalAmplitude);
      }
  }
}