class STTModelPackage {
  final String id;
  final String languageCode;
  final String languageName;
  final String name;
  final int sizeInBytes;
  final List<String> fileNames;
  final String baseUrl;
  final bool isDownloaded;
  final bool isActive;

  const STTModelPackage({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.name,
    required this.sizeInBytes,
    required this.fileNames,
    required this.baseUrl,
    this.isDownloaded = false,
    this.isActive = false,
  });

  double get sizeInMb => sizeInBytes / (1024 * 1024);

  STTModelPackage copyWith({
    bool? isDownloaded,
    bool? isActive,
  }) {
    return STTModelPackage(
      id: id,
      languageCode: languageCode,
      languageName: languageName,
      name: name,
      sizeInBytes: sizeInBytes,
      fileNames: fileNames,
      baseUrl: baseUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isActive: isActive ?? this.isActive,
    );
  }
}
