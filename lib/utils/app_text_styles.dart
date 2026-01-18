import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 제목: 아주 크고 굵게
  static const TextStyle title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black, // 완전 검정
    height: 1.2,
  );

  // 본문 강조: 크고 진하게
  static const TextStyle bodyBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // 본문 일반: 가독성 좋은 크기
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Colors.black87, // 연한 회색 대신 진한 회색
    height: 1.5,
  );
}