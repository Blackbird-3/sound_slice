import "package:flutter/material.dart";
import "package:sound_slice/util/colors.dart";
import "package:sound_slice/util/dimensions.dart";

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
            color: (_page == 0) ? secondaryColor : Colors.black54,),
            label: '',
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audio_file_sharp,
            color: (_page == 1) ? secondaryColor : Colors.black54,),
            label: '',
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
            color: (_page == 2) ? secondaryColor : Colors.black54,),
            label: '',
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          ),
          
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
