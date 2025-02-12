import 'dart:ui';

const List<String> kriyaNames = [
  'Sudarshan Kriya',
  'Medha Yoga',
  'Utkarsh Yoga',
  'Rudra Pooja',
  'Ganesh Homa',
  'Durga Puja',
];

class Tags {
  String name;
  Color color;
  Tags(this.color, this.name);
}

List<Tags> tagList = [
  Tags(const Color(0xFF2F96F5), "Sudarshan Kriya"),
  Tags(const Color(0xFFDA5F90), "Medha"),
  Tags(const Color(0xFF59B43A), "Utkarsh Yoga"),
  Tags(const Color(0xFF2F96F5), "Sudarshan Kriya"),
];
