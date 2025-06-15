// lib/data/models/family_model.dart
// Data models for families, family members, and family invites.

/// Enum for family member roles.
enum FamilyMemberRole {
  head,
  member,
  admin; // Could be used for more granular permissions

  static FamilyMemberRole fromString(String value) {
    try {
      return FamilyMemberRole.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
        orElse: () => FamilyMemberRole.member,
      );
    } catch (_) {
      return FamilyMemberRole.member;
    }
  }

  String toDbString() {
    return toString().split('.').last.toUpperCase();
  }
}

/// Enum for family invite statuses.
enum FamilyInviteStatus {
  pending,
  accepted,
  declined,
  expired;

  static FamilyInviteStatus fromString(String value) {
    try {
      return FamilyInviteStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
        orElse: () => FamilyInviteStatus.pending,
      );
    } catch (_) {
      return FamilyInviteStatus.pending;
    }
  }

  String toDbString() {
    return toString().split('.').last.toUpperCase();
  }
}

/// Represents a family unit.
class Family {
  final String id;
  final String name;
  final String createdBy; // User ID of the creator
  final DateTime createdAt;

  Family({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String,
      name: json['name'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Family copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Represents a member within a family.
class FamilyMember {
  final String familyId;
  final String userId;
  final FamilyMemberRole role;
  final DateTime joinedAt;

  FamilyMember({
    required this.familyId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String,
      role: FamilyMemberRole.fromString(json['role'] as String? ?? 'MEMBER'),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family_id': familyId,
      'user_id': userId,
      'role': role.toDbString(),
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  FamilyMember copyWith({
    String? familyId,
    String? userId,
    FamilyMemberRole? role,
    DateTime? joinedAt,
  }) {
    return FamilyMember(
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

/// Represents an invitation for a user to join a family.
class FamilyInvite {
  final String id;
  final String familyId;
  final String? email; // Invited user's email
  final String? phone; // Invited user's phone
  final String invitedBy; // User ID of the inviter
  final FamilyInviteStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  FamilyInvite({
    required this.id,
    required this.familyId,
    this.email,
    this.phone,
    required this.invitedBy,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  factory FamilyInvite.fromJson(Map<String, dynamic> json) {
    return FamilyInvite(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      invitedBy: json['invited_by'] as String,
      status: FamilyInviteStatus.fromString(json['status'] as String? ?? 'PENDING'),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'email': email,
      'phone': phone,
      'invited_by': invitedBy,
      'status': status.toDbString(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  FamilyInvite copyWith({
    String? id,
    String? familyId,
    String? email,
    String? phone,
    String? invitedBy,
    FamilyInviteStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return FamilyInvite(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      invitedBy: invitedBy ?? this.invitedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
