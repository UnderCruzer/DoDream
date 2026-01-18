import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [필수] 인증 모듈
import 'package:flutter/material.dart';

class BoardService with ChangeNotifier {
  // 파이어스토어 'posts' 컬렉션 연결
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  // 1. 글 읽기
  Stream<QuerySnapshot> getPosts() {
    return postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // 2. 글 쓰기 (배포용 강화 버전)
  Future<void> addPost(String title, String content, String authorName) async {
    // [보안 핵심] 현재 로그인한 사용자의 ID를 가져옴
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("로그인이 필요합니다."); // 로그인이 안 됐으면 실행 차단
    }

    // [중요] 여기가 함수 내부여야 합니다. 괄호 안에 잘 들어있습니다.
    await postsCollection.add({
      'title': title,
      'content': content,
      'author': authorName,
      'uid': user.uid, // 보안 규칙 대조용 ID
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 3. 내 글 삭제하기
  Future<void> deletePost(String docId) {
    return postsCollection.doc(docId).delete();
  }

  // 4. 좋아요
  Future<void> likePost(String docId, int currentLikes) {
    return postsCollection.doc(docId).update({
      'likes': currentLikes + 1,
    });
  }
}