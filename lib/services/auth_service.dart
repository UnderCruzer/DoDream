import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  // 앱 시작 시 자동 실행될 로그인 함수
  Future<void> signInAnonymously() async {
    try {
      // 이미 로그인되어 있는지 확인
      if (_auth.currentUser != null) {
        _user = _auth.currentUser;
      } else {
        // 처음이면 익명 계정 생성 (기기별 고유 ID 부여됨)
        UserCredential credential = await _auth.signInAnonymously();
        _user = credential.user;
      }
      notifyListeners();
    } catch (e) {
      print("로그인 실패: $e");
    }
  }

  // 현재 사용자 ID 가져오기 (글 쓸 때 필요)
  String? get userId => _user?.uid;
}