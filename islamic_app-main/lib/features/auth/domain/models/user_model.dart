import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final DateTime? createdAt;
  final bool hasSubscription;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.createdAt,
    this.hasSubscription = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    DateTime? createdAt,
    bool? hasSubscription,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      hasSubscription: hasSubscription ?? this.hasSubscription,
    );
  }
} 