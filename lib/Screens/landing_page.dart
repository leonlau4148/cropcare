import 'package:cropcare/Screens/edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart%20';
import 'package:cropcare/Cropcarebloc/navigation_bloc/navigation_bloc.dart';
import 'package:cropcare/Screens/home.dart';
import 'package:cropcare/Screens/addcrop.dart';
import 'package:cropcare/Screens/recomendation.dart';

List<BottomNavigationBarItem> bottomNavItems = const <BottomNavigationBarItem>[
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
    backgroundColor: Colors.brown,
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.eco),
    label: 'Crop Recomendation',
    backgroundColor: Colors.brown,
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.add_chart_sharp),
    label: 'Add Crop',
    backgroundColor: Colors.brown,
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.edit_note_outlined),
    label: 'Manage Crops',
    backgroundColor: Colors.brown,
  ),
];

List<Widget> bottomNavScreen = <Widget>[
  //container color
  const HomeScreen(),
  const RecommendScreen(),
  const AddCrop(),
  const EditScreen(),
];

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigationBloc, NavigationState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          body: Center(
            child: bottomNavScreen.elementAt(state.tabIndex),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38, spreadRadius: 0, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10)),
              child: BottomNavigationBar(
                selectedFontSize: 14,
                elevation: 0,
                items: bottomNavItems,
                currentIndex: state.tabIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white,
                onTap: (index) {
                  BlocProvider.of<NavigationBloc>(context)
                      .add(TabChange(tabIndex: index));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
