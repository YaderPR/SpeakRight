import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/presentation/settings/viewmodels/preferences_viewmodel.dart';
import 'package:speak_right/presentation/settings/viewmodels/settings_providers.dart';
import 'package:speak_right/presentation/settings/viewmodels/settings_viewmodel.dart';

class SpeechModelsScreen extends ConsumerWidget {
  const SpeechModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    const bgDark = Color(0xFF0F0F13);
    const surfaceDark = Color(0xFF181822);
    const borderColor = Color(0xFF282835);
    const primaryAccent = Color(0xFF6C5DD3);
    const successColor = Color(0xFF2ED47A);
    const errorColor = Color(0xFFFF5B5C);
    const textMuted = Color(0xFF8A8A9D);

    ref.listen(settingsViewModelProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: errorColor,
            action: SnackBarAction(
              label: l10n.dismiss,
              textColor: Colors.white,
              onPressed: () => viewModel.dismissError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.speechModels,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: state.isLoading && state.availableModels.isEmpty
          ? const Center(child: CircularProgressIndicator(color: primaryAccent))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              itemCount: state.availableModels.length,
              itemBuilder: (context, index) {
                final model = state.availableModels[index];
                final isDownloading = state.downloadingModelId == model.id;
                final isActive = state.activeModel?.id == model.id;
                
                return _buildModelCard(
                  model: model,
                  isActive: isActive,
                  isDownloading: isDownloading,
                  downloadProgress: isDownloading ? state.downloadProgress : 0.0,
                  viewModel: viewModel,
                  surfaceDark: surfaceDark,
                  borderColor: borderColor,
                  primaryAccent: primaryAccent,
                  successColor: successColor,
                  textMuted: textMuted,
                  errorColor: errorColor,
                  l10n: l10n,
                );
              },
            ),
    );
  }

  Widget _buildModelCard({
    required STTModelPackage model,
    required bool isActive,
    required bool isDownloading,
    required double downloadProgress,
    required SettingsViewModel viewModel,
    required Color surfaceDark,
    required Color borderColor,
    required Color primaryAccent,
    required Color successColor,
    required Color textMuted,
    required Color errorColor,
    required AppLocalizations l10n,
  }) {
    final sizeMb = model.sizeInMb.toStringAsFixed(1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? primaryAccent : borderColor,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primaryAccent.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (model.isDownloaded && !isActive) {
              viewModel.selectActiveModel(model.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  model.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (model.isStreaming) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: primaryAccent.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    l10n.streaming,
                                    style: TextStyle(
                                      color: primaryAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${model.languageName} • $sizeMb MB',
                            style: TextStyle(color: textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: successColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: successColor, size: 20),
                      )
                    else if (!model.isDownloaded && !isDownloading)
                      IconButton(
                        icon: const Icon(Icons.download_rounded, color: Colors.white),
                        onPressed: () => viewModel.startDownload(model),
                        style: IconButton.styleFrom(
                          backgroundColor: primaryAccent,
                        ),
                      )
                    else if (model.isDownloaded && !isActive)
                       IconButton(
                        icon: Icon(Icons.delete_outline, color: errorColor.withOpacity(0.8)),
                        onPressed: () => viewModel.removeModel(model),
                      ),
                  ],
                ),
                if (isDownloading) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: downloadProgress,
                            backgroundColor: borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(downloadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
