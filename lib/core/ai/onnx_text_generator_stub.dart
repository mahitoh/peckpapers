class OnnxTextGenerator {
  OnnxTextGenerator({
    this.modelAssetPath = 'assets/models/peckpapers_llm.onnx',
  });

  final String modelAssetPath;

  bool get isAvailable => false;

  Future<void> init() async {}

  Future<String?> generate(String prompt, {int maxTokens = 256}) async => null;

  void dispose() {}
}
