// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertImpl _$$AlertImplFromJson(Map<String, dynamic> json) => _$AlertImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      isPublic: json['isPublic'] as bool,
      status: $enumDecodeNullable(_$AlertStatusEnumMap, json['status']) ??
          AlertStatus.active,
    );

Map<String, dynamic> _$$AlertImplToJson(_$AlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'isPublic': instance.isPublic,
      'status': _$AlertStatusEnumMap[instance.status]!,
    };

const _$AlertTypeEnumMap = {
  AlertType.info: 'info',
  AlertType.buy: 'buy',
  AlertType.sell: 'sell',
  AlertType.all: 'all',
};

const _$AlertStatusEnumMap = {
  AlertStatus.active: 'active',
  AlertStatus.archived: 'archived',
};
