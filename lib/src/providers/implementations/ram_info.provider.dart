// Copyright (c) 2022, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:app_analysis/app_analysis.dart';

class RamInfoAndroidProvider {
  factory RamInfoAndroidProvider() => _instance;
  RamInfoAndroidProvider._();
  static final _instance = RamInfoAndroidProvider._();

  int _parseUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'gb':
        return 1024 * 1024 * 1024;
      case 'mb':
        return 1024 * 1024;
      case 'kb':
        return 1024;
      case 'b':
      default:
        return 1;
    }
  }

  Future<RamInfo> _readInfo() async {
    try {
      final file = File('/proc/meminfo');
      final lines = await file.readAsLines();

      var total = -1;
      var free = -1;
      for (var line in lines) {
        if (line.contains('MemTotal')) {
          final rawTotal = line.split(':').last.trim();
          final parts = rawTotal.split(' ');
          final totalUnmodified = int.parse(parts.first);
          final unitModifier = _parseUnit(parts.last);
          total = (totalUnmodified * unitModifier).toInt();
        }
        if (line.contains('MemAvailable')) {
          final rawFree = line.split(':').last.trim();
          final parts = rawFree.split(' ');
          final freeUnmodified = int.parse(parts.first);
          final unitModifier = _parseUnit(parts.last);
          free = (freeUnmodified * unitModifier).toInt();
        }
      }

      return RamInfo(
        total: total,
        used: total == -1 && free == -1 ? -1 : total - free,
        free: free,
      );
    } catch (e) {
      return kUnknownRamInfo;
    }
  }

  Future<RamInfo> get info => _readInfo();
}
