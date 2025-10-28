import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container with fixed height and full-width image
            Container(
              height: 2200,
              width: double.infinity, // Ensures the container takes full width
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/back.PNG'),
                  fit: BoxFit.fitHeight, // Scales image to cover full width
                ),
              ),
            ),
            // Optional additional space for more scrolling (adjust as needed)
          ],
        ),
      ),
    );
  }
}