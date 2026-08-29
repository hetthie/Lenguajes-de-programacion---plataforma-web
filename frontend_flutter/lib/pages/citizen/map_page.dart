import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/city_map.dart';
import 'detail_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<AppProvider>().complaints;

    return CityMap(
      complaints: complaints,
      onMarkerTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(complaint: item)),
        );
      },
    );
  }
}
