import 'package:flutter/material.dart';
import '../../core/ai/model_health.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_card.dart';

class ModelHealthScreen extends StatelessWidget {
  const ModelHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text('Model Health', style: AppTextStyles.headingLG),
      ),
      body: FutureBuilder<ModelHealthReport>(
        future: const ModelHealthChecker().check(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final report = snapshot.data!;
          final assetOk = report.assetPresent && report.assetBytes > 1024;
          final runtimeOk = report.runtimeReady;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              PeckCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bundled Model', style: AppTextStyles.headingSM),
                    const SizedBox(height: 8),
                    Text(
                      assetOk
                          ? 'Model file detected (${report.assetBytes} bytes).'
                          : 'Model file missing or too small.',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: assetOk ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PeckCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ONNX Runtime', style: AppTextStyles.headingSM),
                    const SizedBox(height: 8),
                    Text(
                      runtimeOk
                          ? 'Runtime session initialized successfully.'
                          : 'Runtime session failed to initialize.',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: runtimeOk ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PeckCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: AppTextStyles.headingSM),
                    const SizedBox(height: 8),
                    Text(
                      'If the model file is a placeholder, the app will fall back to'
                      ' the heuristic summarizer until a real ONNX model is bundled.',
                      style: AppTextStyles.bodyMD,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
