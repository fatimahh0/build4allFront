class SupportInfo {
  final int ownerProjectLinkId;

  final String? ownerName;
  final String? email;
  final String? phoneNumber; // WhatsApp-support number

  const SupportInfo({
    required this.ownerProjectLinkId,
    this.ownerName,
    this.email,
    this.phoneNumber,
  });

  static String? _s(dynamic v) {
    final s = ('${v ?? ''}').trim();
    if (s.isEmpty) return null;
    final low = s.toLowerCase();
    if (low == 'null' || low == 'n/a' || low == 'none') return null;
    return s;
  }

  static int _i(dynamic v, int fallback) {
    if (v is int) return v;
    return int.tryParse('${v ?? ''}') ?? fallback;
  }

  factory SupportInfo.fromJson(Map<String, dynamic> json, int linkId) {
    // supports both flat + nested responses
    Map<String, dynamic> m = json;

    if (m['data'] is Map) m = Map<String, dynamic>.from(m['data'] as Map);
    if (m['support'] is Map) m = Map<String, dynamic>.from(m['support'] as Map);
    if (m['owner'] is Map) {
      // allow owner:{name,email,phoneNumber}
      final owner = Map<String, dynamic>.from(m['owner'] as Map);
      m = {...m, ...owner};
    }

    return SupportInfo(
      ownerProjectLinkId: _i(m['ownerProjectLinkId'] ?? m['linkId'], linkId),
      ownerName: _s(m['ownerName'] ?? m['name']),
      email: _s(m['email']),
      phoneNumber: _s(
        m['phoneNumber'] ??
            m['supportPhoneNumber'] ??
            m['whatsappNumber'] ??
            m['supportWhatsappNumber'],
      ),
    );
  }
}
