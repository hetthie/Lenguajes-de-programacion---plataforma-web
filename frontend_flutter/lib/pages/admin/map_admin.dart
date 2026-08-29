import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/city_map.dart';

class MapAdminPage extends StatelessWidget {
  const MapAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<AppProvider>().complaints;
    return CityMap(complaints: complaints);
  }
}
