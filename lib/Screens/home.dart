import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcare/Routes/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cropcare/Screens/profile.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

int selectedIndexForList = 0;
String c = "\u2103";
String f = "\u2109";
Weather? _weather;

class _HomeScreenState extends State<HomeScreen> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHERAPIKEY);

  List<String> _plantTypes = ['All'];

  @override
  void initState() {
    super.initState();
    _wf.currentWeatherByCityName('Tagum').then((value) => setState(() {
          _weather = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          //floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                // floating: true,
                title: const Text(
                  'CropCare',
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                  ),
                ),
                // add icon
                actions: [
                  IconButton(
                    alignment: Alignment.center,
                    icon: const Icon(
                      Icons.account_circle,
                      color: Colors.brown,
                      size: 32.0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 15,
                  )
                ],
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
                    Container(
                      height: 200,
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
                      //add icon
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          //time
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                DateFormat('hh:mm a').format(
                                    _weather?.date != null
                                        ? _weather!.date!
                                            .add(const Duration(hours: -8))
                                        : DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 30,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          //weather date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                DateFormat('EEEE').format(_weather?.date != null
                                    ? _weather!.date!
                                    : DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                DateFormat('MM.DD.y').format(
                                    _weather?.date != null
                                        ? _weather!.date!
                                        : DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  alignment: Alignment.centerRight,
                                  image: NetworkImage(
                                    'https://openweathermap.org/img/w/${_weather?.weatherIcon}.png',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _weather?.temperature?.celsius
                                        ?.toStringAsFixed(2) ??
                                    'Loading',
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                c,
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _weather?.weatherDescription ?? 'Loading',
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(
                                '${FirebaseAuth.instance.currentUser!.email}')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            // waiting for data
                            return const CircularProgressIndicator();
                          } else if (snapshot.data?.size == 0) {
                            _plantTypes.clear();
                            _plantTypes.add('All');

                            return SizedBox(
                              height: 35,
                              width: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _plantTypes.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndexForList = index;
                                      });
                                    },
                                    child: Container(
                                      //margins
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 5,
                                          bottom: 5),
                                      decoration: BoxDecoration(
                                        color: selectedIndexForList == index
                                            ? Colors.brown
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _plantTypes[index],
                                        style: TextStyle(
                                          color: selectedIndexForList == index
                                              ? Colors.white
                                              : Colors.black54,
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            for (int i = 0;
                                i < snapshot.data!.docs.length;
                                i++) {
                              if (!_plantTypes.contains(
                                  snapshot.data!.docs[i]['Crop Category'])) {
                                _plantTypes.add(
                                    snapshot.data!.docs[i]['Crop Category']);
                              }
                            }
                            //list view _plantypes
                            return SizedBox(
                              height: 35,
                              width: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _plantTypes.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndexForList = index;
                                      });
                                    },
                                    child: Container(
                                      //margins
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 5,
                                          bottom: 5),
                                      decoration: BoxDecoration(
                                        color: selectedIndexForList == index
                                            ? Colors.brown
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _plantTypes[index],
                                        style: TextStyle(
                                          color: selectedIndexForList == index
                                              ? Colors.white
                                              : Colors.black54,
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }),
                    //elevated button
                    const SizedBox(
                      height: 20,
                    ),
                    //if all is selected then show all the crops

                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(
                                '${FirebaseAuth.instance.currentUser!.email}')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            // waiting for data
                            return const CircularProgressIndicator();
                          } else if (snapshot.data?.size == 0) {
                            // collection has no data
                            return const Text('No Crops',
                              style: TextStyle(
                              color: Colors.brown,

                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat',
                            ),
                            );
                          } else {
                            return SizedBox(
                              height: 200,
                              width: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  //if selected index is 0 then show all the crops
                                  if (selectedIndexForList == 0) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          top: 1, bottom: 1, left: 4, right: 4),
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
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 12,
                                          ),
                                          Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                snapshot.data!.docs[index]
                                                    ['Image'],
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                snapshot.data!.docs[index]
                                                    ['Crop Name'],
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                snapshot.data!.docs[index][
                                                        'Soil Minimum Temperature $c'] +
                                                    c +
                                                    ' - ' +
                                                    snapshot.data!.docs[index][
                                                        'Soil Maximum Temperature $c'] +
                                                    c,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  } else if (snapshot.data!.docs[index]
                                          .get('Crop Category') !=
                                      _plantTypes[selectedIndexForList]) {
                                    return const SizedBox();
                                  }

                                  final DocumentSnapshot data =
                                      snapshot.data!.docs[index];

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        top: 1, bottom: 1, left: 4, right: 4),
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      //rounded corner
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(
                                              data['Image'],
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data['Crop Name'],
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data['Soil Minimum Temperature $c'] +
                                                  c +
                                                  ' - ' +
                                                  data[
                                                      'Soil Maximum Temperature $c'] +
                                                  c,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    //recently added
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 35,
                        ),
                        Text(
                          'Recently Added',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(
                                '${FirebaseAuth.instance.currentUser!.email}')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            // waiting for data
                            return const CircularProgressIndicator();
                          } else if (snapshot.data?.size == 0) {
                            // collection has no data
                            return const Text('No Recently Added Crops',
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                              ),
                            );
                          } else {
                            return SizedBox(
                              height: 200,
                              width: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final DocumentSnapshot data =
                                      snapshot.data!.docs[index];
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        top: 1, bottom: 1, left: 4, right: 4),
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      //rounded corner
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(
                                              data['Image'],
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data['Crop Name'],
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data['Soil Minimum Temperature $c'] +
                                                  c +
                                                  ' - ' +
                                                  data[
                                                      'Soil Maximum Temperature $c'] +
                                                  c,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
