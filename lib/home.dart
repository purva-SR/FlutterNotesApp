import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  var errorMessage = "";

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes")
      ),
      body: allNotes.isNotEmpty ? ListView.builder(
          itemCount: allNotes.length,
          itemBuilder: (_, index) {
            return ListTile(
              leading: Text('${allNotes[index][DBHelper.TABLE_COLUMN_SNO]}'),
              title: Text(allNotes[index][DBHelper.TABLE_COLUMN_TITLE]),
              subtitle: Text(allNotes[index][DBHelper.TABLE_COLUMN_DESC]),
              trailing: Container(
                width: 50,
                child: Row(
                  children: [InkWell(onTap: () {
                    showModalBottomSheet(context: context, builder: (context) {
                      titleController.text = allNotes[index][DBHelper.TABLE_COLUMN_TITLE];
                      descController.text = allNotes[index][DBHelper.TABLE_COLUMN_DESC];
                      return getBottomSheet(isUpdate: true, sno: allNotes[index][DBHelper.TABLE_COLUMN_SNO]);
                    });
                  }, child: Icon(Icons.edit)), InkWell(onTap: () async {
                    bool isDelete = await dbRef!.deleteNote(sno: allNotes[index][DBHelper.TABLE_COLUMN_SNO]);
                    if (isDelete) {
                      getNotes();
                    }
                  }, child: Icon(Icons.delete, color: Colors.red,))],
                ),
              ),
            );

      }) : Center(
        child: Text("No notes yet!!"),
      ),

      floatingActionButton: FloatingActionButton(onPressed: () async {

        showModalBottomSheet(context: context, builder: (context) {
          titleController.clear();
          descController.clear();
          return getBottomSheet();
        });
      }, child: Icon(Icons.add),
      ),
    );
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {
    });
  }

  Widget getBottomSheet({isUpdate = false, int sno = 0}) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.maxFinite,
      child: Column(
        children: [
          Text(isUpdate ? "Update Note" : "Add note", style: TextStyle(fontSize: 20, fontWeight: .bold),),
          SizedBox(height: 10),
          TextField(controller: titleController,
            decoration: InputDecoration(
              labelText: "Title",
              hintText: "Enter Title",
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10)
              ),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Description",
              hintText: "Enter Description",
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10)
              ),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child:
              OutlinedButton(style:
              OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 6, color: Colors.black45))),
                  onPressed: () async {
                    var mTitle = titleController.text;
                    var mDesc = descController.text;
                    if (mTitle.isNotEmpty && mDesc.isNotEmpty) {
                      bool isAdded =  isUpdate ? await dbRef!.updateNote(title: mTitle, desc: mDesc, sno: sno) : await dbRef!.addNote(title: mTitle, desc: mDesc);
                      if (isAdded) {
                        getNotes();
                      }
                      Navigator.pop(context);
                    } else {
                      errorMessage = "Title and Description can't be blank";
                      setState(() {
                      });
                    }

                    titleController.clear();
                    descController.clear();
                  }, child: Text(isUpdate ? "Update Note" : "Add Note")),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: OutlinedButton(style:
                OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 6, color: Colors.black45))),
                    onPressed: () {
                      Navigator.pop(context);
                    }, child: Text("Cancel")),
              ),
            ],
          ),
          Text(errorMessage),
        ],
      )
      ,);
  }
}