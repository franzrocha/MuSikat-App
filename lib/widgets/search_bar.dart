// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:musikat_app/screens/home/search_screen.dart';

class Searchbar extends StatelessWidget {
  const Searchbar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          height: 42,
          width: MediaQuery.of(context).size.width / 1.1,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(50)),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
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
                  Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Search',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
