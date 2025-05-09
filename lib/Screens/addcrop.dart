import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcare/Utility/show_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Screens/home.dart';

class AddCrop extends StatefulWidget {
  const AddCrop({super.key});

  @override
  State<AddCrop> createState() => _AddCropState();
}

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

class _AddCropState extends State<AddCrop> {

 //add photo
  UploadTask? uploadTask;
  PlatformFile? pickedFile;
  final email = FirebaseAuth.instance.currentUser!.email;
// variable for celsius and fahrenheit
  String cf = "\u2103";
  String cf2 = "\u2103";
  String c = "\u2103";
  String f = "\u2109";
//text controllers for firebase database
  late final TextEditingController _cropname;
  late final TextEditingController _cropcategory;
  late final TextEditingController _soilmoisture;
  late final TextEditingController _soilmintemp;
  late final TextEditingController _soilmaxtemp;
 //flag for addFunction button
  var isSelected = false;

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

  celToFarMin() {
    setState(() {
      if (cf == c) {
        cf = f;
      } else {
        cf = c;
      }
    });
  }

  celToFarMax() {
    setState(() {
      if (cf2 == c) {
        cf2 = f;
      } else {
        cf2 = c;
      }
    });
  }

  changeValMin(){
    setState(() {
      if (cf == c && _soilmintemp.text.isNotEmpty) {
        //convert to celsius
        double far = double.parse(_soilmintemp.text);
        double cel = (far - 32) * 5 / 9;
        _soilmintemp.text = cel.toStringAsFixed(2);

      } else if (cf == f && _soilmintemp.text.isNotEmpty) {
        //convert to fahrenheit
        double cel = double.parse(_soilmintemp.text);
        double far = (cel * 9 / 5) + 32;
        _soilmintemp.text = far.toStringAsFixed(2);
      }
    });
  }

  changeValMax(){
    setState(() {
      if (cf2 == c && _soilmaxtemp.text.isNotEmpty){
        //convert to celsius
        double far = double.parse(_soilmaxtemp.text);
        double cel = (far - 32) * 5 / 9;
        _soilmaxtemp.text = cel.toStringAsFixed(2);

      } else if (cf2 == f && _soilmaxtemp.text.isNotEmpty) {
        //convert to fahrenheit
        double cel = double.parse(_soilmaxtemp.text);
        double far = (cel * 9 / 5) + 32;
        _soilmaxtemp.text = far.toStringAsFixed(2);

      }
    });
  }

  @override
  void initState() {
    _cropname = TextEditingController();
    _cropcategory = TextEditingController();
    _soilmoisture = TextEditingController();
    _soilmintemp = TextEditingController();
    _soilmaxtemp = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _cropname.dispose();
    _cropcategory.dispose();
    _soilmoisture.dispose();
    _soilmintemp.dispose();
    _soilmaxtemp.dispose();

    super.dispose();
  }

  addFunction() async {


    final cropname = _cropname.text;
    final cropcategory = _cropcategory.text;
    final soilmoisture = _soilmoisture.text;


    //adding picture to firebase
    if (isSelected &&
        cropname.isNotEmpty &&
        cropcategory.isNotEmpty &&
        soilmoisture.isNotEmpty &&
        _soilmintemp.text.isNotEmpty &&
        _soilmaxtemp.text.isNotEmpty) {

      final path = '$email/${pickedFile!.name}';
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref(path);
      setState(() {
        uploadTask = ref.putFile(file);
      });
      final snapshot =
      await uploadTask!.whenComplete(() {});
      final urlDownload =
      await snapshot.ref.getDownloadURL();

      setState(() {
        uploadTask = null;
      });

      String detectMinTemp ='';
      String minans ='';
      if (cf == f){
        //convert to celsius
        double far = double.parse(_soilmintemp.text);
        double cel = (far - 32) * 5 / 9;
        minans = cel.toStringAsFixed(2);
        detectMinTemp = c;
      } else if (cf == c){
        //convert to fahrenheit
        double cel = double.parse(_soilmintemp.text);
        double far = (cel * 9 / 5) + 32;
        minans = far.toStringAsFixed(2);
        detectMinTemp = f;
      }
      String detectMaxTemp ='';
      String maxans ='';
      if (cf2 == f){
        //convert to celsius
        double far = double.parse(_soilmaxtemp.text);
        double cel = (far - 32) * 5 / 9;
        maxans = cel.toStringAsFixed(2);
        detectMaxTemp = c;

      } else if (cf2 == c){
        //convert to fahrenheit
        double cel = double.parse(_soilmaxtemp.text);
        double far = (cel * 9 / 5) + 32;
        maxans = far.toStringAsFixed(2);
        detectMaxTemp = f;
      }

      //adding crop to cloud database
      await FirebaseFirestore.instance
          .collection('$email').doc(cropname).set({
        'Crop Name': cropname,
        'Crop Category': cropcategory,
        'Soil Moisture': soilmoisture,
        'Soil Minimum Temperature $cf': _soilmintemp.text + (' '),
        'Soil Maximum Temperature $cf2': _soilmaxtemp.text + (' '),
        'Soil Minimum Temperature $detectMinTemp': minans,
        'Soil Maximum Temperature $detectMaxTemp': maxans,
        'Image': urlDownload,
        'timestamp' : Timestamp.now(),
      });
      if (context.mounted) {
        await showDialogPromt(context, "Adding Crop",
            "$cropname added successfully");
      }
      //clearing addcrop
      _soilmaxtemp.clear();
      _soilmintemp.clear();
      _soilmoisture.clear();
      _cropcategory.clear();
      _cropname.clear();
      isSelected = false;
      pickedFile = null;
    } else {
      if (context.mounted) {
        await showDialogPromt(context, "Adding Crop",
            "EmptyFields or No Image Selected");
        isSelected = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          // floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(
                // floating: true,
                title: Text(
                  'Add Crop',
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                  ),
                ),
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
                    //container
                    const SizedBox(
                      height: 25,
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
                            ] else ...const [
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
                    const SizedBox(
                      height: 20,
                    ),

                    ///crop name
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
                            controller: _cropcategory,
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

                    ///soil moisture
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

                    ///Soil Temperature Minimum
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
                            controller: _soilmintemp,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 20),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            celToFarMin();

                            changeValMin();
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

                    ///Soil Temperature Maximum
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
                            controller: _soilmaxtemp,
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
                      height: 20,
                    ),
                    ///button to add crop
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
                            selectedIndexForList = 0;
                            addFunction();
                          },
                          child: const Text(
                            'Add Crop',
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
                  ],
                ),
              ),
            ),
          )),
    );
  }


}
