import 'package:flutter/material.dart';

class LoginTopImage extends StatelessWidget {
  final double height;

  const LoginTopImage({super.key, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Transform.translate(
            offset: const Offset(-20, 0),
            child: Transform.scale(
              scaleX: 1.15,
              child: Image.asset(
                'assets/images/image-top-login.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
