import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcare/Utility/show_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
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

class _RecommendScreenState extends State<RecommendScreen> {
  //text controllers for firebase database
  late final TextEditingController _soilmoisture;
  late final TextEditingController _soiltemp;

  @override
  void initState() {
    _soilmoisture = TextEditingController();
    _soiltemp = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _soilmoisture.dispose();
    _soiltemp.dispose();

    super.dispose();
  }

  String c = "\u2103";
  String f = "\u2109";
  String cf2 = "\u2103";

  celToFar() {
    setState(() {
      if (cf2 == c) {
        cf2 = f;
      } else {
        cf2 = c;
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

  getData() async {
    final soilmoisture = _soilmoisture.text;
    final soiltemp = _soiltemp.text;
    //check if the fields are empty
    if (selectedClient == "0" ||
        _soilmoisture.text.isEmpty ||
        _soiltemp.text.isEmpty) {
      showDialogPromt(context, "Error", "Please fill all the fields.");
    } else {
      //call the firebase database
      await FirebaseFirestore.instance
          .collection('${FirebaseAuth.instance.currentUser!.email}')
          .get()
          .then(
        //using query snapshot
        (querySnapshot) {
          //loop through the documents
          for (var docSnapshot in querySnapshot.docs) {
            final data = docSnapshot.data();
            //get the data from the database
            var value = data['Crop Name'];
            var value1 = data['Soil Minimum Temperature $c'];
            var value2 = data['Soil Maximum Temperature $c'];
            var value3 = data['Soil Minimum Temperature $f'];
            var value4 = data['Soil Maximum Temperature $f'];
            var value5 = data['Soil Moisture'];
            //convert to double
            double mintempdbC = double.parse(value1);
            double maxtempdbC = double.parse(value2);
            double mintempdbF = double.parse(value3);
            double maxtempdbF = double.parse(value4);
            double txttemp = double.parse(soiltemp);
            //for the soil temperature
            if (selectedClient == value) {
              if (cf2 == c) {
                if (txttemp < mintempdbC) {
                  recommendedResultTemp =
                      'The soil temperature is too low for this crop it should be at $mintempdbC$c to $maxtempdbC$c ($mintempdbF$f to $maxtempdbF$f).';
                } else if (txttemp > maxtempdbC) {
                  recommendedResultTemp =
                      'The soil temperature is too high for this crop it should be at $mintempdbC$c to $maxtempdbC$c ($mintempdbF$f to $maxtempdbF$f).';
                } else if (txttemp >= mintempdbC && txttemp <= maxtempdbC) {
                  recommendedResultTemp =
                      'The soil temperature is optimal for this crop.';
                } else {
                  recommendedResultTemp =
                      'The soil temperature is optimal for this crop.';
                }
              } else {
                if (txttemp < mintempdbF) {
                  recommendedResultTemp =
                      'The soil temperature is too low for this crop it should be at $mintempdbF$f to $maxtempdbF$f ($mintempdbC$c to $maxtempdbC$c).';
                } else if (txttemp > maxtempdbF) {
                  recommendedResultTemp =
                      'The soil temperature is too high for this crop it should be at $mintempdbF$f to $maxtempdbF$f ($mintempdbC$c to $maxtempdbC$c).';
                } else if (txttemp >= mintempdbF && txttemp <= maxtempdbF) {
                  recommendedResultTemp =
                      'The soil temperature is optimal for this crop.';
                } else {
                  recommendedResultTemp =
                      'The soil temperature is optimal for this crop.';
                }
              }
            }
            //for the soil moisture
            if (selectedClient == value) {
              if (soilmoisture == value5) {
                recommendedResultMoisture =
                    'The soil moisture is optimal for this crop';
              } else if (soilmoisture == "Dry") {
                recommendedResultMoisture =
                    "Increase watering the crop soil moisture should be '$value5'.";
              } else if (soilmoisture == "Wet") {
                recommendedResultMoisture =
                    "Decrease watering the crop soil moisture should be '$value5'.";
              } else {
                recommendedResultMoisture =
                    "The soil moisture is not optimal for this crop should be '$value5'.";
              }
            }
          }
          //show the dialog
          if (context.mounted) {
            showDialogPromt(context, "Recommendation",
                "$recommendedResultMoisture\n\n$recommendedResultTemp");
          }
        },
      );
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
                  'Recommendation',
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
                          }
                          else {
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
                              hintText: 'Soil Moisture',
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
                              hintText: 'Soil Temperature',
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
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      onPressed: () {
                        setState(() {
                          getData();
                        });
                      },
                      child: const Text(
                        'Get Recommendations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
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
