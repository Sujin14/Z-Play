class LibrarySettings {
  const LibrarySettings({
    this.darkTheme = true,
    this.includeShortClips = false,
    this.includeSystemSounds = false,
    this.hiddenFolders = const [],
  });

  final bool darkTheme;
  final bool includeShortClips;
  final bool includeSystemSounds;
  final List<String> hiddenFolders;

  static const int minimumClipMs = 60000;

  LibrarySettings copyWith({
    bool? darkTheme,
    bool? includeShortClips,
    bool? includeSystemSounds,
    List<String>? hiddenFolders,
  }) {
    return LibrarySettings(
      darkTheme: darkTheme ?? this.darkTheme,
      includeShortClips: includeShortClips ?? this.includeShortClips,
      includeSystemSounds: includeSystemSounds ?? this.includeSystemSounds,
      hiddenFolders: hiddenFolders ?? this.hiddenFolders,
    );
  }
}
