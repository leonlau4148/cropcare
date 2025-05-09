import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cropcare/Utility/show_error_dialog.dart';
import 'package:cropcare/Utility/show_dialog.dart';
import 'package:cropcare/Routes/constants/routes.dart';
import 'package:flutter/services.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
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

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _name;
  late final TextEditingController _number;
  late final TextEditingController _address;

  var isSelected = false;

  UploadTask? uploadTask;
  PlatformFile? pickedFile;

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
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _name = TextEditingController();
    _number = TextEditingController();
    _address = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _number.dispose();
    _address.dispose();
    super.dispose();
  }

  registerFunc() async {


    final email = _email.text;
    final password = _password.text;
    final number = _number.text;
    final name = _name.text;
    final address = _address.text;

    if (isSelected &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        number.isNotEmpty &&
        name.isNotEmpty &&
        address.isNotEmpty) {

      try {
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
        await FirebaseFirestore.instance.collection('users').doc(email).set({
          'email': email,
          'password': password,
          'name': name,
          'phone number': number,
          'address': address,
          'image': urlDownload,
        });

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = FirebaseAuth.instance.currentUser;
        await user?.sendEmailVerification();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);

        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          if (e.code == 'weak-password') {
            await showErrorDialog(
              context,
              'Weak Password',
            );
          } else if (e.code == 'email-already-in-use') {
            await showErrorDialog(
              context,
              'The account already exists for that email.',
            );
          } else if (e.code == 'invalid-email') {
            await showErrorDialog(
              context,
              'The email address is not valid.',
            );
          } else {
            await showErrorDialog(
              context,
              'Error ${e.code}',
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          await showErrorDialog(
            context,
            e.toString(),
          );
        }
      }

      _name.clear();
      _email.clear();
      _password.clear();
      _number.clear();
      _address.clear();
      isSelected = false;
      pickedFile = null;


    }
    else {
      if (context.mounted) {
        await showDialogPromt(context, "Register",
            "Empty Fields or No Image Selected");
        isSelected = false;
      }
    }


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
                  'Register',
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
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Email',
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              )
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
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                     const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Password',
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              )
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
                              controller: _password,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Name',
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              )
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
                              inputFormatters: <TextInputFormatter>[
                                UpperCaseTextFormatter()
                              ],
                              controller: _name,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 20),
                              ),
                            ),
                          ),
                        ],
                      ),

                     const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Phone Number',
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              )
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
                              controller: _number,
                              enableSuggestions: false,
                              autocorrect: false,
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

                      const  SizedBox(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Address',
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              )
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
                              controller: _address,
                              enableSuggestions: false,
                              autocorrect: false,
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

                      const  SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: ()  {
                          registerFunc();

                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                        },
                        child: const Text(
                          "Already registered? Login here",
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
