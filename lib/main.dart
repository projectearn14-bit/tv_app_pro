import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';

void main() => runApp(const MaterialApp(home: TVEngine(), debugShowCheckedModeBanner: false));

class TVEngine extends StatefulWidget {
  const TVEngine({super.key});
  @override
  State<TVEngine> createState() => _TVEngineState();
}

class _TVEngineState extends State<TVEngine> {
  List<dynamic> allChannels = [];
  List<String> favorites = [];
  List<String> recent = [];
  bool isAdBlocked = false;

  // 1. YOUR REVENUE DATA
  String adCode = """<script type='text/javascript' src='//www.profitablecpmratenetwork.com/tmit15ri4?key=43c4129bda0d3aa9e82a122ef3875019'></script>""";
  String scriptUrl = "https://script.google.com/macros/s/AKfycbzYTTxTrPWGO0HPHiF6c0W8zuzAAcysLFE8NBUaL2AviJSaOSm4GwMLHp79jwVeH00Aeg/exec";

  @override
  void initState() {
    super.initState();
    loadAppData();
  }

  Future<void> loadAppData() async {
    try {
      var adCheck = await http.get(Uri.parse('https://adsterra.com')).timeout(const Duration(seconds: 5));
      if (adCheck.statusCode != 200) { setState(() => isAdBlocked = true); return; }

      final prefs = await SharedPreferences.getInstance();
      favorites = prefs.getStringList('favs') ?? [];
      recent = prefs.getStringList('recent') ?? [];

      var response = await http.get(Uri.parse(scriptUrl));
      setState(() { allChannels = json.decode(response.body); });
    } catch (e) { print("Error: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    if (isAdBlocked) return const Scaffold(body: Center(child: Text("Please Disable Adblock")));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ListView(
            children: [
              _buildRow("1. FAVORITES", allChannels.where((c) => favorites.contains(c['id'].toString())).toList()),
              _buildRow("2. RECENTLY VIEWED", allChannels.where((c) => recent.contains(c['id'].toString())).toList()),
              _buildRow("3. TOP REGIONAL", allChannels.where((c) => c['region'] == 'TS/AP' || c['region'] == 'National').toList()),
            ],
          ),
          // 0.5 OPACITY GHOST AD
          Positioned(
            bottom: 0, left: 0, right: 0, height: 80,
            child: Opacity(
              opacity: 0.5,
              child: InAppWebView(initialData: InAppWebViewInitialData(data: adCode)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, List<dynamic> channels) {
    if (channels.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(12.0), child: Text(title, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: channels.length,
            itemBuilder: (context, i) => Card(
              color: Colors.grey[900],
              child: Container(width: 180, child: Center(child: Text(channels[i]['name'], style: TextStyle(color: Colors.white)))),
            ),
          ),
        ),
      ],
    );
  }
}
