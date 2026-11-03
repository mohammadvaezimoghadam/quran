/// Unique target identifiers for spotlight walkthrough items.
enum WalkthroughTargetId {
  // Home Screen Targets
  homeSurahList,
  homeTranslations,
  homeTafsir,
  homeTafakor,

  // Reader Screen Targets
  readerPinchZoom,
  readerFirstAyah,
  readerSettings,
  readerPlayerSettings,
  readerSleepTimer,
  readerAmbientAudio,

  // Ayah Action Bottom Sheet Targets
  dialogTafakorItem,

  // Tafakor Community (Ayah Notes Sheet) Targets
  tafakorWriteButton,

  // Tafakor Editor Screen Targets
  editorAttachedAyah,
  editorInputField,
  editorSendButton,

  // Study Settings (Quick Settings Drawer) Targets
  settingsTranslationSelector,
  settingsReciterSelector,
  settingsAudioTranslationMode,

  // Ambiance (Naghmeh) Bottom Sheet Targets
  ambianceToggleSwitch,

  // Sleep Timer Bottom Sheet Targets
  sleepTimerToggleSwitch,
}

/// Identifiers for tour completion persistence.
enum WalkthroughTourKey {
  home('walkthrough_seen_home_v1'),
  reader('walkthrough_seen_reader_v1'),
  ayahDialog('walkthrough_seen_ayah_dialog_v1'),
  tafakorNotes('walkthrough_seen_tafakor_notes_v1'),
  tafakorEditor('walkthrough_seen_tafakor_editor_v1'),
  studySettings('walkthrough_seen_study_settings_v1'),
  ambianceDialog('walkthrough_seen_ambiance_dialog_v1'),
  sleepTimerDialog('walkthrough_seen_sleep_timer_dialog_v1');

  final String storageKey;
  const WalkthroughTourKey(this.storageKey);
}

