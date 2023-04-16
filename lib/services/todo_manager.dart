import 'package:cloud_firestore/cloud_firestore.dart';

class TodoManager {

  static Stream getTodoList() {
   return FirebaseFirestore.instance.collection('todolist').snapshots();
  }

  static Future<void> createTodo(String newTitle) async {
    try {
      await FirebaseFirestore.instance.collection('todolist').add({
        'title': newTitle,
        'isCompleted': false,
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> updateTodo(String id, String newTitle, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance.collection('todolist').doc(id).update({
        'title': newTitle,
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteTodo(String id) async {
    try {
      await FirebaseFirestore.instance.collection('todolist').doc(id).delete();
    } catch (e) {
      print(e);
    }
  }
}