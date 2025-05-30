// Copyright (c) 2022, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_analysis/app_analysis.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppAnalysis Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AnalysisInfoInterface? info;
  String? cpuInfo;
  String? memInfo;
  String? btrInfo;

  String getInfoData() {
    final raw = info?.toMap() ?? {};
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(raw);
  }

  @override
  void initState() {
    AppAnalyser().initialise();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppAnalysis Example'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => AppAnalyser().start(),
              child: const Text('Start Analysis'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                info = await AppAnalyser().stop();
                setState(() {});
              },
              child: const Text('Stop Analysis'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                final rq = await HttpClient().getUrl(
                  Uri.parse('https://dummy-json.mock.beeceptor.com/continents'),
                );
                final rs = await rq.close();
                AppAnalyser().collectTraffic(
                  HttpClientTrafficConsumptionAdapter(
                    HttpClientRequestResponse(rq.toExtended(), rs.toExtended()),
                  ),
                );
                setState(() {});
              },
              child: const Text('Make Dummy HttpClient Request'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(getInfoData()),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                final provider = CpuInfoProvider();
                cpuInfo = 'Temp: ${await provider.temperature}\n'
                    'Avg Temp: ${await provider.averageTemperature}\n'
                    'Curr Freq: ${await provider.currentFrequency}\n'
                    'Extremum Freq: ${await provider.extremumFrequency}';
                setState(() {});
              },
              child: const Text('Get Cpu Info'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(cpuInfo ?? '-'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                final info = await RamInfoProvider().info;
                memInfo = 'Total: ${info.total.inMiB.toInt()}\n'
                    'Free: ${info.available.inMiB.toInt()}\n'
                    'Used: ${info.used.inMiB.toInt()}';
                setState(() {});
              },
              child: const Text('Get Memory Info'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(memInfo ?? '-'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                final temperature = await BatteryInfoProvider().temperature;
                final chargeLevel = await BatteryInfoProvider().chargeLevel;
                btrInfo = 'Temp: $temperature\n'
                    'Level: $chargeLevel';
                setState(() {});
              },
              child: const Text('Get Battery Info'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(btrInfo ?? '-'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
