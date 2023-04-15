import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  List todoList = [];
  String newTodoTitle = "";
  Stream todoListStream =
      FirebaseFirestore.instance.collection('todolist').snapshots();

  Future<void> createTodo() async {
    try {
      await FirebaseFirestore.instance.collection('todolist').add({
        'title': newTodoTitle,
        'completed': false,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateTodo(String id, String title) async {
    try {
      await FirebaseFirestore.instance.collection('todolist').doc(id).update({
        'title': title,
        'completed': false,
      });
    } catch (e) {
      print(e);
    }
  }

  void onAddTodoClick() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text('New todo'),
          content: TextField(
            onChanged: (String value) {
              newTodoTitle = value;
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await createTodo();
                setState(() {
                  todoList.add(newTodoTitle);
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void editTodo(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text('Edit todo'),
          content: TextField(
            onChanged: (String value) {
              newTodoTitle = value;
            },
            controller: TextEditingController(text: title),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await updateTodo(id, newTodoTitle);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Todo list'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: onAddTodoClick,
          label: const Text('Add todo'),
        ),
        body: StreamBuilder(
          stream: todoListStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return CircularProgressIndicator();
            }

            List<DocumentSnapshot> documents = snapshot.data.docs;

            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (BuildContext context, int index) {
               /* String todoTitle = (documents[index].data()
                as Map<String, dynamic>)['title'] as String;*/

                String todoTitle = documents[index].get('title') as String;
                bool todoCompleted = documents[index].get('completed') as bool;

                return Dismissible(
                  key: Key(todoTitle),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: Checkbox(
                        activeColor: Colors.transparent,
                        checkColor: Colors.cyanAccent,
                        shape: CircleBorder(),
                        value: todoCompleted,
                        onChanged: (bool? value) async {
                          await FirebaseFirestore.instance
                              .collection('todolist')
                              .doc(snapshot.data?.docs[index].id)
                              .update({
                            'completed': value ?? false
                          });
                          setState(() {
                          });
                        },
                      ),
                      title: Text(todoTitle,
                        style: TextStyle(
                          decoration: (todoCompleted == true)
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          editTodo(
                            context,
                            snapshot.data?.docs[index].id,
                            snapshot.data?.docs[index]['title'],
                          );
                        },
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      documents[index].reference.delete();
                    });
                  },
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                              "Are you sure you wish to delete this item?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
    );
  }
}
