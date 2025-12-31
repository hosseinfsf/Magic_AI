import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ai_provider.dart';

class HistoryEntry {
  final AiProviderType provider;
  final DateTime timestamp;
  final String request;
  final String response;
  final Map<String, dynamic>? meta;

  HistoryEntry({
    required this.provider,
    required this.timestamp,
    required this.request,
    required this.response,
    this.meta,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'timestamp': timestamp.toIso8601String(),
        'request': request,
        'response': response,
        if (meta != null) 'meta': meta,
      };

  static HistoryEntry fromJson(Map<String, dynamic> json) => HistoryEntry(
        provider: AiProviderType.values.firstWhere(
          (e) => e.name == json['provider'],
          orElse: () => AiProviderType.gemini,
        ),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        request: json['request'] ?? '',
        response: json['response'] ?? '',
        meta: (json['meta'] as Map?)?.cast<String, dynamic>(),
      );
}

abstract class HistoryStore {
  Future<void> add(HistoryEntry entry);
  Future<List<HistoryEntry>> list({int? limit, AiProviderType? provider});
  Future<void> clear();
}

/// Simple SharedPreferences backed store suitable for MVP
class LocalHistoryStore implements HistoryStore {
  static const _kKey = 'ai_history_entries_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<void> add(HistoryEntry entry) async {
    final prefs = await _prefs;
    final items = prefs.getStringList(_kKey) ?? <String>[];
    items.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_kKey, items);
  }

  @override
  Future<List<HistoryEntry>> list({int? limit, AiProviderType? provider}) async {
    final prefs = await _prefs;
    final items = prefs.getStringList(_kKey) ?? <String>[];
    final all = items
        .map((e) {
          try {
            return HistoryEntry.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<HistoryEntry>()
        .toList()
        .reversed
        .toList(); // newest first

    final filtered = provider == null
        ? all
        : all.where((h) => h.provider == provider).toList();

    return limit != null && limit > 0 && filtered.length > limit
        ? filtered.take(limit).toList()
        : filtered;
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_kKey);
  }
}
