// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      numeroTelephone: json['numeroTelephone'] as String,
      ethnie: json['ethnie'] as String,
      motDePasse: json['motDePasse'] as String,
      codeInvitation: json['codeInvitation'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'numeroTelephone': instance.numeroTelephone,
      'ethnie': instance.ethnie,
      'motDePasse': instance.motDePasse,
      'codeInvitation': instance.codeInvitation,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
      'userId': instance.userId,
      'email': instance.email,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'role': instance.role,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'] as String,
      motDePasse: json['motDePasse'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'motDePasse': instance.motDePasse,
    };
