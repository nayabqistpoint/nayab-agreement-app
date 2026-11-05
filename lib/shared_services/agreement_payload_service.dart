class AgreementPayloadService {
  static Map<String, dynamic> wrapIntoBatchMap(List<dynamic> payloads) {
    final Map<String, dynamic> batchMap = {};
    for (final payload in payloads) {
      if (payload is Map) {
        final key = payload['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();
        batchMap[key] = payload;
      }
    }
    return batchMap;
  }
}
