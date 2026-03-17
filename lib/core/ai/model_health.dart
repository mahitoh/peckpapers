import 'package:flutter/services.dart';

import 'onnx_text_generator.dart';

class ModelHealthReport {
  const ModelHealthReport({
    required this.assetPresent,
    required this.assetBytes,
    required this.runtimeReady,
  });

  final bool assetPresent;
  final int assetBytes;
  final bool runtimeReady;
}

class ModelHealthChecker {
  const ModelHealthChecker({
    this.modelAssetPath = 'assets/models/peckpapers_llm.onnx',
  });

  final String modelAssetPath;

  Future<ModelHealthReport> check() async {
    int bytes = 0;
    bool present = false;
    try {
      final data = await rootBundle.load(modelAssetPath);
      bytes = data.lengthInBytes;
      present = bytes > 0;
    } catch (_) {
      present = false;
    }

    final generator = OnnxTextGenerator(modelAssetPath: modelAssetPath);
    await generator.init();
    final runtimeReady = generator.isAvailable;
    generator.dispose();

    return ModelHealthReport(
      assetPresent: present,
      assetBytes: bytes,
      runtimeReady: runtimeReady,
    );
  }
}
