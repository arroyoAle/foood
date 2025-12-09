import 'package:flutter/material.dart';
import 'package:spin_wheel/partials/drawer.dart';
import 'package:spin_wheel/partials/top_bar.dart';

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key});

  final String title = 'Spin Wheel Page';
  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'spinPage'),
    );
  }
}