// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      userAge: $enumDecodeNullable(_$UserAgeEnumMap, json['userAge']),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'userAge': _$UserAgeEnumMap[instance.userAge],
    };

const _$UserAgeEnumMap = {
  UserAge.age30: 'age30',
  UserAge.age40: 'age40',
  UserAge.age50: 'age50',
  UserAge.age60: 'age60',
  UserAge.age70: 'age70',
  UserAge.age80: 'age80',
};
