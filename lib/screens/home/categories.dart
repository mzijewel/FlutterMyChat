import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;

  const Category({this.name, this.icon});
}

const List<Category> categories = [
  Category(name: "Chats", icon: Icons.assessment),
  Category(name: "Friends", icon: Icons.code),
  Category(name: "Profile", icon: Icons.account_circle),
];
