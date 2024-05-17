// import "package:flutter/material.dart";
// import "package:google_nav_bar/google_nav_bar.dart";
// import "package:sound_slice/util/colors.dart";
// import "package:sound_slice/util/dimensions.dart";

// class MobileScreenLayout extends StatefulWidget {
//   const MobileScreenLayout({super.key});

//   @override
//   State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
// }

// class _MobileScreenLayoutState extends State<MobileScreenLayout> {
//   int _page = 0;
//   late PageController pageController; // for tabs animation

//   @override
//   void initState() {
//     super.initState();
//     pageController = PageController();

//   }

//   @override
//   void dispose() {
//     super.dispose();
//     pageController.dispose();
//   }

//   void onPageChanged(int page) {
//     setState(() {
//       _page = page;
//     });
//   }

//   void navigationTapped(int page) {
//     //Animating Page
//     pageController.jumpToPage(page);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: homeScreenItems.elementAt(_page),
//       // body: PageView(
//       //   controller: pageController,
//       //   onPageChanged: onPageChanged,
//       //   children: homeScreenItems,
//       // ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   items:  [
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.home,
//       //       color: (_page == 0) ? secondaryColor : Colors.black54,),
//       //       label: '',
//       //       backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.audio_file_sharp,
//       //       color: (_page == 1) ? secondaryColor : Colors.black54,),
//       //       label: '',
//       //       backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
//       //     ),

//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.person,
//       //       color: (_page == 2) ? secondaryColor : Colors.black54,),
//       //       label: '',
//       //       backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
//       //     ),

//       //   ],
//       //   onTap: navigationTapped,
//       //   currentIndex: _page,
//       // ),

//       bottomNavigationBar: const GNav(
//         gap: 10,
//         backgroundColor: primaryColor,
//         color: secondaryColor,
//         activeColor: secondaryColor,
//         tabs: [
//         GButton(icon: Icons.home,
//         text: 'Home',),
//         GButton(icon: Icons.audio_file_sharp,
//         text: 'Files',),
//         GButton(icon: Icons.person,
//         text: 'Profile',),

//       ],
//       selectedIndex: _page,),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sound_slice/util/colors.dart';
import 'package:sound_slice/util/dimensions.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  _MobileScreenLayoutState createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController _pageController = PageController(initialPage: _page);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: GNav(
            gap: 10,
            backgroundColor: secondaryColor,
            color: Colors.white,
            activeColor: Colors.white,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                iconColor: Colors.white,
              ),
              GButton(
                icon: Icons.audio_file_sharp,
                text: 'Files',
                iconColor: Colors.white,
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                iconColor: Colors.white,
              ),
            ],
            selectedIndex: _page,
            onTabChange: navigationTapped,
          ),
        ),
      ),
    );
  }
}
