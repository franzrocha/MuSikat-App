import 'package:flutter/material.dart';
import 'package:musikat_app/screens/home/search_screen.dart';

class Searchbar extends StatelessWidget {
  const Searchbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width / 1.45,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: const [
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.search_rounded, color: Colors.black),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Search',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
