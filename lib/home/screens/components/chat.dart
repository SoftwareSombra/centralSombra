import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeChat extends StatelessWidget {
  const HomeChat({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: height * 0.03),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/chat', arguments: uid);
            },
            child: Card(
              elevation: 5,
              child: SizedBox(
                height: 70,
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox.shrink(),
                          Row(
                            children: [
                              Icon(
                                Icons.chat,
                                size: 21,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'FALE COM A CENTRAL',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue,),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 20,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
