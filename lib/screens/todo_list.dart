import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/services/todo_manager.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  List todoList = [];
  Stream todoListStream = TodoManager.getTodoList();

  void onAddTodoClick() {
    String newTitle = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text('New task'),
          content: TextField(
            onChanged: (String value) {
              newTitle = value;
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Colors.cyanAccent,
                ),
              ),
              onPressed: () async {
                await TodoManager.createTodo(newTitle);
                setState(() {
                  todoList.add(newTitle);
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    ).then((value) => todoListStream =
        FirebaseFirestore.instance.collection('todolist').snapshots());
  }

  void onEditTodoClick(
      BuildContext context, String id, String title, bool isCompleted) {
    String newTitle = "";
    TextEditingController controllerTitle = TextEditingController(text: title);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text('Edit todo'),
          content: TextField(
            onChanged: (String value) {
              newTitle = value;
            },
            controller: controllerTitle,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Colors.cyanAccent,
                ),
              ),
              onPressed: () async {
                await TodoManager.updateTodo(id, newTitle, isCompleted);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    ).then((value) => todoListStream =
        FirebaseFirestore.instance.collection('todolist').snapshots());
  }

  void onRemoveClick(BuildContext context, String id) async {
    TodoManager.deleteTodo(id);
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
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading"));
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (BuildContext context, int index) {
              final document = snapshot.data?.docs[index];

              String title = document['title'];
              bool isCompleted = document['isCompleted'];

              return Dismissible(
                key: Key(document.id),
                direction: DismissDirection.horizontal,
                background: Container(

                ),
                secondaryBackground: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Checkbox(
                      activeColor: Colors.transparent,
                      checkColor: Colors.cyanAccent,
                      shape: const CircleBorder(),
                      value: isCompleted,
                      onChanged: (bool? value) async {
                        await FirebaseFirestore.instance
                            .collection('todolist')
                            .doc(document.id)
                            .update({'isCompleted': value ?? false});
                        setState(() {});
                      },
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        decoration: (isCompleted == true)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        onEditTodoClick(
                          context,
                          document.id,
                          title,
                          isCompleted,
                        );
                      },
                    ),
                  ),
                ),
                onDismissed: (direction) {
                  setState(() {
                    onRemoveClick(context, document.id);
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
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
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
