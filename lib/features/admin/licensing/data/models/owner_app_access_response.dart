enum PlanCode { FREE, PRO_HOSTEDB, DEDICATED }

enum SubscriptionStatus { ACTIVE, EXPIRED, SUSPENDED, CANCELED }

PlanCode _planCodeFrom(String v) {
  switch (v) {
    case 'FREE':
      return PlanCode.FREE;
    case 'PRO_HOSTEDB':
      return PlanCode.PRO_HOSTEDB;
    case 'DEDICATED':
      return PlanCode.DEDICATED;
    default:
      return PlanCode.FREE;
  }
}

SubscriptionStatus _subStatusFrom(String v) {
  switch (v) {
    case 'ACTIVE':
      return SubscriptionStatus.ACTIVE;
    case 'EXPIRED':
      return SubscriptionStatus.EXPIRED;
    case 'SUSPENDED':
      return SubscriptionStatus.SUSPENDED;
    case 'CANCELED':
      return SubscriptionStatus.CANCELED;
    default:
      return SubscriptionStatus.EXPIRED;
  }
}

class OwnerAppAccessResponse {
  final bool canAccessDashboard;
  final String? blockingReason;

  final PlanCode? planCode;
  final String? planName;

  final SubscriptionStatus? subscriptionStatus;
  final String? periodEnd; // keep as string unless you need DateTime parsing
  final int daysLeft;

  final int? usersAllowed;
  final int activeUsers;
  final int? usersRemaining;

  final bool requiresDedicatedServer;
  final bool dedicatedInfraReady;

  OwnerAppAccessResponse({
    required this.canAccessDashboard,
    required this.blockingReason,
    required this.planCode,
    required this.planName,
    required this.subscriptionStatus,
    required this.periodEnd,
    required this.daysLeft,
    required this.usersAllowed,
    required this.activeUsers,
    required this.usersRemaining,
    required this.requiresDedicatedServer,
    required this.dedicatedInfraReady,
  });

  factory OwnerAppAccessResponse.fromJson(Map<String, dynamic> j) {
    return OwnerAppAccessResponse(
      canAccessDashboard: j['canAccessDashboard'] == true,
      blockingReason: j['blockingReason'] as String?,
      planCode: j['planCode'] != null ? _planCodeFrom(j['planCode']) : null,
      planName: j['planName'] as String?,
      subscriptionStatus: j['subscriptionStatus'] != null
          ? _subStatusFrom(j['subscriptionStatus'])
          : null,
      periodEnd: j['periodEnd']?.toString(),
      daysLeft: (j['daysLeft'] ?? 0) is int
          ? (j['daysLeft'] ?? 0)
          : int.tryParse('${j['daysLeft']}') ?? 0,
      usersAllowed: j['usersAllowed'] as int?,
      activeUsers: (j['activeUsers'] ?? 0) is int
          ? (j['activeUsers'] ?? 0)
          : int.tryParse('${j['activeUsers']}') ?? 0,
      usersRemaining: j['usersRemaining'] == null
          ? null
          : (j['usersRemaining'] as num).toInt(),
      requiresDedicatedServer: j['requiresDedicatedServer'] == true,
      dedicatedInfraReady: j['dedicatedInfraReady'] == true,
    );
  }
}
