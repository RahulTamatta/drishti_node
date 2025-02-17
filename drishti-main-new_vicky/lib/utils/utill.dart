import 'package:flutter/material.dart';

Widget buildLoading() => const Center(
    heightFactor: 50,
    widthFactor: 50,
    child: CircularProgressIndicator(
      color: Color.fromRGBO(65, 203, 195, 1),
    ));
