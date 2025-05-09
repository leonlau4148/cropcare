import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcare/Routes/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final email = FirebaseAuth.instance.currentUser!.email;

  Future<String> getData() async {
    final DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();
    final data = documentSnapshot.data() as Map<String, dynamic>;
    var value = data['name'];
    return value;
  }

  Future<String> getDataAddress() async {
    final DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();
    final data = documentSnapshot.data() as Map<String, dynamic>;
    var value = data['address'];
    return value;
  }

  Future<String> getDataPhone() async {
    final DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();
    final data = documentSnapshot.data() as Map<String, dynamic>;
    var value = data['phone number'];
    return value;
  }

  Future<String> getDataImage() async {
    final DocumentSnapshot documentSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(email).get();
    final data = documentSnapshot.data() as Map<String, dynamic>;
    var value = data['image'];
    return value;
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
                'Profile',
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
        body: FutureBuilder(
            future: Future.wait([getData(), getDataAddress(), getDataPhone(), getDataImage()]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      //add image here
                      const SizedBox(
                        height: 100.0,
                      ),
                       CircleAvatar(
                        radius: 50.0,
                        backgroundImage:
                            NetworkImage((snapshot.data?[3])),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        (snapshot.data?[0]),
                        style: const TextStyle(
                          color: Colors.brown,
                          fontFamily: 'Times New Roman',
                          fontSize: 29.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      //white box with icon and text
                      Container(
                        height: 60.0,
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
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20.0,
                            ),
                            const Icon(
                              Icons.phone,
                              color: Colors.brown,
                            ),
                            const SizedBox(
                              width: 30.0,
                            ),
                            Text(
                              (snapshot.data?[2]),
                              style: const TextStyle(
                                color: Colors.brown,
                                fontFamily: 'Times New Roman',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      // white box with icon and text
                      Container(
                        height: 60.0,
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
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20.0,
                            ),
                            const Icon(
                              Icons.email,
                              color: Colors.brown,
                            ),
                            const SizedBox(
                              width: 30.0,
                            ),
                            Text(
                              '$email',
                              style: const TextStyle(
                                color: Colors.brown,
                                fontFamily: 'Times New Roman',
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      // white box with icon and text
                      Container(
                        height: 60.0,
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
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20.0,
                            ),
                            const Icon(
                              Icons.add_home_sharp,
                              color: Colors.brown,
                            ),
                            const SizedBox(
                              width: 30.0,
                            ),
                            Text(
                              (snapshot.data?[1]),
                              style: const TextStyle(
                                color: Colors.brown,
                                fontFamily: 'Times New Roman',
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      //ElevatedButton
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute,
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('Logout',
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        )
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      //elevated button
                    ],
                  ),
                );

                // return Text(snapshot.data.toString());
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
