import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utility/show_dialog.dart';
import '../Screens/home.dart';



class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

String selectedClient = "0";
String recommendedResultTemp = '';
String recommendedResultMoisture = '';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}

class _EditScreenState extends State<EditScreen> {
  UploadTask? uploadTask;
  PlatformFile? pickedFile;
  String url='';
  String cname = '';


  var isSelected = false;
  //text controllers for firebase database
  late final TextEditingController _cropname;
  late final TextEditingController _cropcategory;
  late final TextEditingController _soilmoisture;
  late final TextEditingController _soiltemp;
  late final TextEditingController _soiltemp2;

  @override
  void initState() {
    _cropname = TextEditingController();
    _cropcategory = TextEditingController();
    _soilmoisture = TextEditingController();
    _soiltemp = TextEditingController();
    _soiltemp2 = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _cropname.dispose();
    _cropcategory.dispose();
    _soilmoisture.dispose();
    _soiltemp.dispose();
    _soiltemp2.dispose();
    super.dispose();
  }

  String c = "\u2103";
  String f = "\u2109";
  String cf2 = "\u2103";
  String cf = "\u2103";

  celToFar() {
    setState(() {
      if (cf2 == c) {
        cf2 = f;
      } else {
        cf2 = c;
      }
    });
  }

  celToFarMax() {
    setState(() {
      if (cf == c) {
        cf = f;
      } else {
        cf = c;
      }
    });
  }

  changeVal() {
    setState(() {
      if (cf2 == c && _soiltemp.text.isNotEmpty) {
        //convert to celsius
        double far = double.parse(_soiltemp.text);
        double cel = (far - 32) * 5 / 9;
        _soiltemp.text = cel.toStringAsFixed(2);
      } else if (cf2 == f && _soiltemp.text.isNotEmpty) {
        //convert to fahrenheit
        double cel = double.parse(_soiltemp.text);
        double far = (cel * 9 / 5) + 32;
        _soiltemp.text = far.toStringAsFixed(2);
      }
    });
  }

  changeValMax() {
    setState(() {
      if (cf == c && _soiltemp2.text.isNotEmpty) {
        //convert to celsius
        double far = double.parse(_soiltemp2.text);
        double cel = (far - 32) * 5 / 9;
        _soiltemp2.text = cel.toStringAsFixed(2);
      } else if (cf == f && _soiltemp2.text.isNotEmpty) {
        //convert to fahrenheit
        double cel = double.parse(_soiltemp2.text);
        double far = (cel * 9 / 5) + 32;
        _soiltemp2.text = far.toStringAsFixed(2);
      }
    });
  }

  saveData() async {
    final soilmoisture = _soilmoisture.text;
    final soiltemp = _soiltemp.text;
    final soiltemp2 = _soiltemp2.text;
    final cropname = _cropname.text;
    final cropcategory = _cropcategory.text;


    //check if the fields are empty
    if (selectedClient == "0" ||
        _soilmoisture.text.isEmpty ||
        _soiltemp.text.isEmpty ||
        _soiltemp2.text.isEmpty ||
        _cropname.text.isEmpty ||
        _cropcategory.text.isEmpty ||
        url == '' && pickedFile == null) {
      showDialogPromt(context, "Error", "Please fill all the fields, select a Crop and pick an image.");
    } else {
      //check if the image is selected
      if (isSelected == true) {
        final email = FirebaseAuth.instance.currentUser!.email;
        final path = '$email/${pickedFile!.name}';
        final file = File(pickedFile!.path!);
        final ref = FirebaseStorage.instance.ref(path);
        setState(() {
          uploadTask = ref.putFile(file);
        });
        final snapshot = await uploadTask!.whenComplete(() {});
        url = await snapshot.ref.getDownloadURL();
      }
      String detectMinTemp ='';
      String minans ='';
      if (cf == f){
        //convert to celsius
        double far = double.parse(soiltemp);
        double cel = (far - 32) * 5 / 9;
        minans = cel.toStringAsFixed(2);
        detectMinTemp = c;
      } else if (cf == c){
        //convert to fahrenheit
        double cel = double.parse(soiltemp);
        double far = (cel * 9 / 5) + 32;
        minans = far.toStringAsFixed(2);
        detectMinTemp = f;
      }
      String detectMaxTemp ='';
      String maxans ='';
      if (cf2 == f){
        //convert to celsius
        double far = double.parse(soiltemp2);
        double cel = (far - 32) * 5 / 9;
        maxans = cel.toStringAsFixed(2);
        detectMaxTemp = c;

      } else if (cf2 == c){
        //convert to fahrenheit
        double cel = double.parse(soiltemp2);
        double far = (cel * 9 / 5) + 32;
        maxans = far.toStringAsFixed(2);
        detectMaxTemp = f;
      }

      //adding crop to cloud database
      await FirebaseFirestore.instance
          .collection( '${FirebaseAuth.instance.currentUser!.email}').doc(cropname).set({
        'Crop Name': cropname,
        'Crop Category': cropcategory,
        'Soil Moisture': soilmoisture,
        'Soil Minimum Temperature $cf': soiltemp,
        'Soil Maximum Temperature $cf2': soiltemp2,
        'Soil Minimum Temperature $detectMinTemp': minans,
        'Soil Maximum Temperature $detectMaxTemp': maxans,
        'Image' : url,
        'timestamp' : Timestamp.now(),

      });


      if (context.mounted) {
        showDialogPromt(context, "Success", "Data updated successfully.");
      }
      if (cname != cropname){
         FirebaseFirestore.instance
            .collection('${FirebaseAuth.instance.currentUser!.email}')
            .doc(cname)
            .delete();
      }

      setState(() {
        _cropname.clear();
        _cropcategory.clear();
        _soilmoisture.clear();
        _soiltemp.clear();
        _soiltemp2.clear();
        selectedClient = "0";
        url = '';
        pickedFile = null;
        isSelected = false;
        cname = '';
      });
    }
  }

  getData() async {
    await FirebaseFirestore.instance
        .collection('${FirebaseAuth.instance.currentUser!.email}')
        .doc(selectedClient)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (selectedClient == documentSnapshot['Crop Name']) {
          setState(() {
            _cropname.text = documentSnapshot['Crop Name'];
            cname = documentSnapshot['Crop Name'];
            _cropcategory.text = documentSnapshot['Crop Category'];
            _soilmoisture.text = documentSnapshot['Soil Moisture'];
            url = documentSnapshot['Image'];
            if (cf2 == c) {
              _soiltemp.text = documentSnapshot['Soil Minimum Temperature $c'];

            } else {
              _soiltemp.text = documentSnapshot['Soil Minimum Temperature $f'];

            }
            if (cf == c) {
              _soiltemp2.text = documentSnapshot['Soil Maximum Temperature $c'];

            } else {
              _soiltemp2.text = documentSnapshot['Soil Maximum Temperature $f'];

            }
          });
        }
      }
    });
  }

  deleteData () async {


    if (selectedClient == "0") {
      showDialogPromt(context, "Error", "Please select a crop to delete.");
    } else {

      await FirebaseFirestore.instance
          .collection('${FirebaseAuth.instance.currentUser!.email}')
          .doc(selectedClient)
          .delete();
      if (context.mounted){
        showDialogPromt(context, "Success", "Data deleted successfully.");
      }

    }

  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      //  allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
    isSelected = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          //floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(
                // floating: true,
                title: Text(
                  'Manage Crops',
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                  ),
                ),
                backgroundColor: Colors.white,
              ),
            ];
          },
          body: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),

                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(
                                '${FirebaseAuth.instance.currentUser!.email}')
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<DropdownMenuItem> clientItems = [];
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            final clients =
                                snapshot.data?.docs.reversed.toList();
                            clientItems.add(
                              const DropdownMenuItem(
                                value: '0',
                                child: Text(
                                  'Select Crop',
                                ),
                              ),
                            );
                            for (var client in clients!) {
                              clientItems.add(
                                DropdownMenuItem(
                                  value: client.id,
                                  child: Text(
                                    client['Crop Name'],
                                  ),
                                ),
                              );
                            }
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Crop Name: ',
                                style: TextStyle(
                                  color: Colors.brown,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              DropdownButton(
                                items: clientItems,
                                onChanged: (clientValue) {
                                  setState(() {
                                    selectedClient = clientValue;
                                  });

                                  if (selectedClient != "0"){
                                    getData();
                                  }
                                  else{
                                    setState(() {
                                      _cropname.clear();
                                      _cropcategory.clear();
                                      _soilmoisture.clear();
                                      _soiltemp.clear();
                                      _soiltemp2.clear();
                                      url = '';
                                    });
                                  }

                                },
                                value: selectedClient,
                                isExpanded: false,
                              ),
                            ],
                          );
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        selectFile();
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                            )
                          ],
                        ),
                        //add icon
                        child: Column(
                          children: [
                            if (pickedFile != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(pickedFile!.path!),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ]
                            else if(
                              url.isNotEmpty && url!= ''
                            )...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  url,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ]

                            else ...const [
                              SizedBox(
                                height: 35,
                              ),
                              Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.brown,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Add Image',
                                style: TextStyle(
                                  color: Colors.brown,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    ///cropname
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Crop Name',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 350,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _cropname,
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter()
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    ///crop category
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Crop Category',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 350,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _cropcategory,
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter()
                            ],
                            decoration: const InputDecoration(

                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Soil Moisture',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    //min temp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 350,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                              )
                            ],
                          ),
                          child: TextField(
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter()
                            ],
                            controller: _soilmoisture,
                            decoration: const InputDecoration(

                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Soil Minimum Temperature',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ///min temp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 310,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                              )
                            ],
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d+)?\.?\d{0,2}')),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'))
                            ],
                            controller: _soiltemp,
                            decoration: const InputDecoration(

                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 20),
                            ),
                          ),
                        ),
                        //icon
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            celToFar();
                            changeVal();
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                cf2,
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    ///max temp
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Soil Maximum Temperature',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 310,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                              )
                            ],
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d+)?\.?\d{0,2}')),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'))
                            ],
                            controller: _soiltemp2,
                            decoration: const InputDecoration(

                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 20),
                            ),
                          ),
                        ),
                        //icon
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            celToFarMax();
                            changeValMax();
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                cf,
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                          ),
                          onPressed: () {
                            setState(() {
                              saveData();
                            });
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                     //delete button with alert dialog
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Delete"),
                                    content: const Text(
                                        "Are you sure you want to delete this crop?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {

                                            selectedIndexForList = 0;
                                            deleteData();
                                            _cropname.clear();
                                            _cropcategory.clear();
                                            _soilmoisture.clear();
                                            _soiltemp.clear();
                                            _soiltemp2.clear();
                                            selectedClient = "0";
                                            url = '';
                                            pickedFile = null;
                                            isSelected = false;
                                            cname = '';
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                          ),
                          onPressed: () {
                            setState(() {
                              _cropname.clear();
                              _cropcategory.clear();
                              _soilmoisture.clear();
                              _soiltemp.clear();
                              _soiltemp2.clear();
                              selectedClient = "0";
                              url = '';
                              pickedFile = null;
                              isSelected = false;
                              cname = '';
                            });
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                  ],
                ),
              ),
            ),
          )),
    );
  }
}
