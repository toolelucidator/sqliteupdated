import 'package:flutter/material.dart';
import 'dbmanager.dart';
import 'Student.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Student>>? Studentss;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerApepa = TextEditingController();
  TextEditingController controllerApema = TextEditingController();
  TextEditingController controllerTel = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();

  String? name = '';
  String? apepa = '';
  String? apema = '';
  String? tel = '';
  String? email = '';
  int? currentUserId;
  final formKey = GlobalKey<FormState>();
  late var dbHelper;
  late bool isUpdating;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = dbManager();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      Studentss = dbHelper.getStudents();
      //Studentss = dbHelper.customQuery("JORGE.@.COM");
    });
  }

  clearData() {
    controllerName.text = "";
    controllerApepa.text = "";
    controllerApema.text = "";
    controllerTel.text = "";
    controllerEmail.text = "";
  }

  validate() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isUpdating) {
        Student stu = Student(currentUserId, name, apepa, apema, tel, email);
        dbHelper.update(stu);
        setState(() {
          isUpdating = false;
        });
      } else {
        Student stu = Student(null, name, apepa, apema, tel, email);
        dbHelper.save(stu);
      }
      clearData();
      refreshList();
    }
  }

  Widget form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: controllerName,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              validator: (val) => val!.isEmpty ? 'Ingrese un nombre' : null,
              onSaved: (val) => name = val,
            ),
            TextFormField(
              controller: controllerApepa,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Apellido Paterno',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              validator: (val) => val!.isEmpty ? 'Ingrese Apellido' : null,
              onSaved: (val) => apepa = val,
            ),
            TextFormField(
              controller: controllerApema,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Apellido Materno',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              validator: (val) => val!.isEmpty ? 'Ingrese Apellido' : null,
              onSaved: (val) => apema = val,
            ),
            TextFormField(
              controller: controllerTel,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              validator: (val) => val!.isEmpty ? 'Ingrese Teléfono' : null,
              onSaved: (val) => tel = val,
            ),
            TextFormField(
              controller: controllerEmail,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              validator: (val) => val!.isEmpty ? 'E-mail' : null,
              onSaved: (val) => email = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: validate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: Text(isUpdating ? 'Actualizar' : 'Insertar'),
                ),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      isUpdating = false;
                    });
                    clearData();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("Cancelar"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Student>? Studentss) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Paterno')),
          DataColumn(label: Text('Materno')),
          DataColumn(label: Text('Tel')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Borrar')),
        ],
        rows: Studentss!
            .map((mapStudent) => DataRow(cells: [
          DataCell(Text(mapStudent.name!), onTap: () {
            setState(() {
              isUpdating = true;
              currentUserId = mapStudent.controlNum;
            });
            controllerName.text = mapStudent.name!;
            controllerApepa.text = mapStudent.apepa!;
            controllerApema.text = mapStudent.apema!;
            controllerTel.text = mapStudent.tel!;
            controllerEmail.text = mapStudent.email!;
          }),
          DataCell(Text(mapStudent.apepa!)),
          DataCell(Text(mapStudent.apema!)),
          DataCell(Text(mapStudent.tel!)),
          DataCell(Text(mapStudent.email!)),
          DataCell(IconButton(
            onPressed: () {
              dbHelper.delete(mapStudent.controlNum);
              refreshList();
            },
            icon: const Icon(Icons.delete),
          ))
        ]))
            .toList(),
      ),
    );
  }

  Widget list() {
    return Expanded(
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: Studentss,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                  return dataTable(snapshot.data);
                }
                if (snapshot.hasData == null) {
                  print("Data not Found");
                }
                return const CircularProgressIndicator();
              }),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQLite CRUD Operations"),
        centerTitle: true,
      ),
      body: (Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: [

          form(),
          list(),
        ],
      )),
    );
  }
}
