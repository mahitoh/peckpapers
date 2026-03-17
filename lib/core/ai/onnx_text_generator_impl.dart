import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class OnnxTextGenerator {
  OnnxTextGenerator({
    this.modelAssetPath = 'assets/models/peckpapers_llm.onnx',
  });

  final String modelAssetPath;
  OrtSession? _session;
  bool _initialized = false;
  bool _available = false;

  bool get isAvailable => _available;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      OrtEnv.instance.init();
      final raw = await rootBundle.load(modelAssetPath);
      final bytes = raw.buffer.asUint8List();
      if (bytes.lengthInBytes < 1024) {
        _available = false;
        return;
      }
      final options = OrtSessionOptions();
      _session = OrtSession.fromBuffer(bytes, options);
      _available = _session != null;
    } catch (_) {
      _available = false;
    }
  }

  Future<String?> generate(String prompt, {int maxTokens = 256}) async {
    await init();
    if (!_available || _session == null) return null;

    // NOTE: Proper LLM inference requires a tokenizer and model-specific
    // input/output handling. This placeholder returns null so the
    // heuristic pipeline can run until a compatible model is added.
    return null;
  }

  void dispose() {
    _session?.release();
    _session = null;
    _available = false;
  }
}
