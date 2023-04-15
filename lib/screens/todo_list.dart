import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {

  List todoList = [];
  String newTodo = "";
  Stream todoListStream = FirebaseFirestore.instance.collection('todolist').snapshots();


  void addTodo() {
    DocumentReference ref = FirebaseFirestore.instance.collection(
        "todolist").doc(newTodo);
    Map<String, String> todoList = {
      "title": newTodo
    };
    ref.set(todoList).whenComplete(() => print("$newTodo created"));
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
                newTodo = value;
              },
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    todoList.add(newTodo);
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
            ],
          );
        });
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

            List<DocumentSnapshot> documents = snapshot.data?.docs;

            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (BuildContext context, int index) {

                String todoTitle = (documents[index].data() as Map<String, dynamic>)['title'] as String;
                return Dismissible(
                  key: Key(todoTitle),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(todoTitle),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            documents[index].reference.delete();
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        )
      /*body: ListView.builder(
        itemCount: todoList.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(todoList[index]),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text(todoList[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      todoList.removeAt(index);
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),*/
    );
  }
}