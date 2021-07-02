import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unit/views/pages/app/bloc_wrapper.dart';
import 'views/pages/app/flutter_unit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //滚动性能优化 1.22.0
  GestureBinding.instance.resamplingEnabled = true;
  runApp(BlocWrapper(child: FlutterUnit()));
}


