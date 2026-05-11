import 'package:flutter/foundation.dart';

import 'onscreen_gamepad_models.dart';

const kOnscreenGamepadProfileStoreVersion = 1;

class OnscreenGamepadProfileStore {
  const OnscreenGamepadProfileStore({
    this.version = kOnscreenGamepadProfileStoreVersion,
    required this.activeProfileId,
    required this.profiles,
  });

  factory OnscreenGamepadProfileStore.fromJson(Map<String, Object?> json) {
    final profiles = _list(json['p'])
        .whereType<Map>()
        .map((item) => OnscreenGamepadProfile.fromJson(_map(item)))
        .toList();
    final activeProfileId = _string(
      json['a'],
      _firstOrNull(profiles)?.id ?? '',
    );

    return OnscreenGamepadProfileStore(
      version: _int(json['v'], kOnscreenGamepadProfileStoreVersion),
      activeProfileId: activeProfileId,
      profiles: profiles,
    ).normalized();
  }

  final int version;
  final String activeProfileId;
  final List<OnscreenGamepadProfile> profiles;

  OnscreenGamepadProfile? get activeProfile {
    for (final profile in profiles) {
      if (profile.id == activeProfileId) {
        return profile;
      }
    }
    return _firstOrNull(profiles);
  }

  Map<String, Object?> toJson() {
    return {
      'v': version,
      'a': activeProfileId,
      'p': profiles.map((profile) => profile.toJson()).toList(),
    };
  }

  OnscreenGamepadProfileStore copyWith({
    int? version,
    String? activeProfileId,
    List<OnscreenGamepadProfile>? profiles,
  }) {
    return OnscreenGamepadProfileStore(
      version: version ?? this.version,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      profiles: profiles ?? this.profiles,
    ).normalized();
  }

  OnscreenGamepadProfileStore normalized() {
    if (profiles.isEmpty) {
      return OnscreenGamepadProfileStore(
        version: version,
        activeProfileId: '',
        profiles: const [],
      );
    }
    if (profiles.any((profile) => profile.id == activeProfileId)) {
      return this;
    }
    return OnscreenGamepadProfileStore(
      version: version,
      activeProfileId: profiles.first.id,
      profiles: profiles,
    );
  }

  OnscreenGamepadProfileStore setActiveProfile(String profileId) {
    if (!profiles.any((profile) => profile.id == profileId)) {
      return normalized();
    }
    return copyWith(activeProfileId: profileId);
  }

  OnscreenGamepadProfileStore upsertProfile(
    OnscreenGamepadProfile profile, {
    bool activate = false,
  }) {
    final nextProfiles = [...profiles];
    final index = nextProfiles.indexWhere((item) => item.id == profile.id);
    if (index == -1) {
      nextProfiles.add(profile);
    } else {
      nextProfiles[index] = profile;
    }

    return copyWith(
      activeProfileId: activate ? profile.id : activeProfileId,
      profiles: nextProfiles,
    );
  }

  OnscreenGamepadProfileStore removeProfile(String profileId) {
    final nextProfiles = [
      for (final profile in profiles)
        if (profile.id != profileId) profile,
    ];
    final nextActiveProfileId = activeProfileId == profileId
        ? _firstOrNull(nextProfiles)?.id ?? ''
        : activeProfileId;

    return copyWith(
      activeProfileId: nextActiveProfileId,
      profiles: nextProfiles,
    );
  }

  OnscreenGamepadProfileStore duplicateProfile(
    String sourceProfileId, {
    required String id,
    required String name,
    bool activate = true,
  }) {
    final source = profiles.firstWhere(
      (profile) => profile.id == sourceProfileId,
      orElse: () => throw ArgumentError.value(
        sourceProfileId,
        'sourceProfileId',
        'Unknown profile id',
      ),
    );
    return upsertProfile(
      source.copyWith(id: id, name: name),
      activate: activate,
    );
  }
}

class OnscreenGamepadProfileController extends ChangeNotifier {
  OnscreenGamepadProfileController(OnscreenGamepadProfileStore store)
    : _store = store.normalized();

  OnscreenGamepadProfileStore _store;

  OnscreenGamepadProfileStore get store => _store;
  OnscreenGamepadProfile? get activeProfile => _store.activeProfile;

  void replaceStore(OnscreenGamepadProfileStore store) {
    _store = store.normalized();
    notifyListeners();
  }

  void setActiveProfile(String profileId) {
    _store = _store.setActiveProfile(profileId);
    notifyListeners();
  }

  void upsertProfile(OnscreenGamepadProfile profile, {bool activate = false}) {
    _store = _store.upsertProfile(profile, activate: activate);
    notifyListeners();
  }

  void removeProfile(String profileId) {
    _store = _store.removeProfile(profileId);
    notifyListeners();
  }

  void updateProfile(
    String profileId,
    OnscreenGamepadProfile Function(OnscreenGamepadProfile profile) update,
  ) {
    final profile = _store.profiles.firstWhere(
      (item) => item.id == profileId,
      orElse: () => throw ArgumentError.value(
        profileId,
        'profileId',
        'Unknown profile id',
      ),
    );
    upsertProfile(update(profile));
  }

  void addControl(OnscreenGamepadControl control, {String? profileId}) {
    updateProfile(profileId ?? _store.activeProfileId, (profile) {
      return profile.copyWith(controls: [...profile.controls, control]);
    });
  }

  void updateControl(OnscreenGamepadControl control, {String? profileId}) {
    updateProfile(profileId ?? _store.activeProfileId, (profile) {
      return profile.copyWith(
        controls: [
          for (final item in profile.controls)
            if (item.id == control.id) control else item,
        ],
      );
    });
  }

  void removeControl(String controlId, {String? profileId}) {
    updateProfile(profileId ?? _store.activeProfileId, (profile) {
      return profile.copyWith(
        controls: [
          for (final control in profile.controls)
            if (control.id != controlId) control,
        ],
      );
    });
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return const {};
}

List<Object?> _list(Object? value) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  return const [];
}

String _string(Object? value, String fallback) {
  return value is String ? value : fallback;
}

int _int(Object? value, int fallback) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

T? _firstOrNull<T>(List<T> values) {
  return values.isEmpty ? null : values.first;
}
