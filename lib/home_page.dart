import 'package:db_with_sqflite/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  dbHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = dbHelper.getinstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body:
          allNotes.isEmpty
              ? const Center(child: Text('No Notes'))
              : ListView.builder(
                itemCount: allNotes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      allNotes[index][dbHelper.COLUMN_NOTE_TITLE] ?? '',
                    ),
                    subtitle: Text(
                      allNotes[index][dbHelper.COLUMN_NOTE_DESC] ?? '',
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              titleController.text =
                                  allNotes[index][dbHelper.COLUMN_NOTE_TITLE];
                              descController.text =
                                  allNotes[index][dbHelper.COLUMN_NOTE_DESC];

                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return BottomSheetWidget(
                                    isUpdate: true,
                                    sno:
                                        allNotes[index][dbHelper
                                            .COLUMN_NOTE_SNO],
                                    titleController: titleController,
                                    descController: descController,
                                    onSave: getNotes,
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool check = await dbRef!.deleteNotes(
                                sno: allNotes[index][dbHelper.COLUMN_NOTE_SNO],
                              );
                              if (check) {
                                getNotes();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Note Deleted')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleController.clear();
          descController.clear();

          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheetWidget(
                isUpdate: false,
                titleController: titleController,
                descController: descController,
                onSave: getNotes,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  final bool isUpdate;
  final int sno;
  final TextEditingController titleController;
  final TextEditingController descController;
  final VoidCallback onSave;

  const BottomSheetWidget({
    super.key,
    this.isUpdate = false,
    this.sno = 0,
    required this.titleController,
    required this.descController,
    required this.onSave,
  });

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  dbHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = dbHelper.getinstance;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isUpdate ? 'UPDATE NOTE' : 'ADD NOTE',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: 'Enter Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.descController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final title = widget.titleController.text.trim();
                    final desc = widget.descController.text.trim();

                    if (title.isEmpty || desc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all the fields'),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    bool check =
                        widget.isUpdate
                            ? await dbRef!.updateNotes(
                              title: title,
                              desc: desc,
                              sno: widget.sno,
                            )
                            : await dbRef!.addNote(title: title, desc: desc);

                    if (check) {
                      widget.onSave();
                      widget.titleController.clear();
                      widget.descController.clear();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Operation failed')),
                      );
                    }
                  },
                  child: Text(widget.isUpdate ? 'Update Note' : 'Add Note'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
