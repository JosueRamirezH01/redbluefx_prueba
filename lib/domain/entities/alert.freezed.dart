// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Alert _$AlertFromJson(Map<String, dynamic> json) {
  return _Alert.fromJson(json);
}

/// @nodoc
mixin _$Alert {
  String get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String get pair => throw _privateConstructorUsedError;
  String get entry => throw _privateConstructorUsedError;
  String get stopLoss => throw _privateConstructorUsedError;
  AlertType get type => throw _privateConstructorUsedError;
  String? get analysis => throw _privateConstructorUsedError;
  List<String> get takeProfits => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  AlertStatus get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AlertCopyWith<Alert> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertCopyWith<$Res> {
  factory $AlertCopyWith(Alert value, $Res Function(Alert) then) =
      _$AlertCopyWithImpl<$Res, Alert>;
  @useResult
  $Res call(
      {String id,
      String? title,
      String? content,
      String pair,
      String entry,
      String stopLoss,
      AlertType type,
      String? analysis,
      List<String> takeProfits,
      String? image,
      String? imageUrl,
      DateTime createdAt,
      String createdBy,
      bool isPublic,
      AlertStatus status});
}

/// @nodoc
class _$AlertCopyWithImpl<$Res, $Val extends Alert>
    implements $AlertCopyWith<$Res> {
  _$AlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? content = freezed,
    Object? pair = null,
    Object? entry = null,
    Object? stopLoss = null,
    Object? type = null,
    Object? analysis = freezed,
    Object? takeProfits = null,
    Object? image = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? isPublic = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      pair: null == pair
          ? _value.pair
          : pair // ignore: cast_nullable_to_non_nullable
              as String,
      entry: null == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as String,
      stopLoss: null == stopLoss
          ? _value.stopLoss
          : stopLoss // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      analysis: freezed == analysis
          ? _value.analysis
          : analysis // ignore: cast_nullable_to_non_nullable
              as String?,
      takeProfits: null == takeProfits
          ? _value.takeProfits
          : takeProfits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AlertStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertImplCopyWith<$Res> implements $AlertCopyWith<$Res> {
  factory _$$AlertImplCopyWith(
          _$AlertImpl value, $Res Function(_$AlertImpl) then) =
      __$$AlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? title,
      String? content,
      String pair,
      String entry,
      String stopLoss,
      AlertType type,
      String? analysis,
      List<String> takeProfits,
      String? image,
      String? imageUrl,
      DateTime createdAt,
      String createdBy,
      bool isPublic,
      AlertStatus status});
}

/// @nodoc
class __$$AlertImplCopyWithImpl<$Res>
    extends _$AlertCopyWithImpl<$Res, _$AlertImpl>
    implements _$$AlertImplCopyWith<$Res> {
  __$$AlertImplCopyWithImpl(
      _$AlertImpl _value, $Res Function(_$AlertImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? content = freezed,
    Object? pair = null,
    Object? entry = null,
    Object? stopLoss = null,
    Object? type = null,
    Object? analysis = freezed,
    Object? takeProfits = null,
    Object? image = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? isPublic = null,
    Object? status = null,
  }) {
    return _then(_$AlertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      pair: null == pair
          ? _value.pair
          : pair // ignore: cast_nullable_to_non_nullable
              as String,
      entry: null == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as String,
      stopLoss: null == stopLoss
          ? _value.stopLoss
          : stopLoss // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      analysis: freezed == analysis
          ? _value.analysis
          : analysis // ignore: cast_nullable_to_non_nullable
              as String?,
      takeProfits: null == takeProfits
          ? _value._takeProfits
          : takeProfits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AlertStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertImpl implements _Alert {
  const _$AlertImpl(
      {required this.id,
      this.title,
      this.content,
      required this.pair,
      required this.entry,
      required this.stopLoss,
      required this.type,
      this.analysis,
      required final List<String> takeProfits,
      this.image,
      this.imageUrl,
      required this.createdAt,
      required this.createdBy,
      required this.isPublic,
      this.status = AlertStatus.active})
      : _takeProfits = takeProfits;

  factory _$AlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertImplFromJson(json);

  @override
  final String id;
  @override
  final String? title;
  @override
  final String? content;
  @override
  final String pair;
  @override
  final String entry;
  @override
  final String stopLoss;
  @override
  final AlertType type;
  @override
  final String? analysis;
  final List<String> _takeProfits;
  @override
  List<String> get takeProfits {
    if (_takeProfits is EqualUnmodifiableListView) return _takeProfits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_takeProfits);
  }

  @override
  final String? image;
  @override
  final String? imageUrl;
  @override
  final DateTime createdAt;
  @override
  final String createdBy;
  @override
  final bool isPublic;
  @override
  @JsonKey()
  final AlertStatus status;

  @override
  String toString() {
    return 'Alert(id: $id, title: $title, content: $content, pair: $pair, entry: $entry, stopLoss: $stopLoss, type: $type, analysis: $analysis, takeProfits: $takeProfits, image: $image, imageUrl: $imageUrl, createdAt: $createdAt, createdBy: $createdBy, isPublic: $isPublic, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.pair, pair) || other.pair == pair) &&
            (identical(other.entry, entry) || other.entry == entry) &&
            (identical(other.stopLoss, stopLoss) ||
                other.stopLoss == stopLoss) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.analysis, analysis) ||
                other.analysis == analysis) &&
            const DeepCollectionEquality()
                .equals(other._takeProfits, _takeProfits) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      content,
      pair,
      entry,
      stopLoss,
      type,
      analysis,
      const DeepCollectionEquality().hash(_takeProfits),
      image,
      imageUrl,
      createdAt,
      createdBy,
      isPublic,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      __$$AlertImplCopyWithImpl<_$AlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertImplToJson(
      this,
    );
  }
}

abstract class _Alert implements Alert {
  const factory _Alert(
      {required final String id,
      final String? title,
      final String? content,
      required final String pair,
      required final String entry,
      required final String stopLoss,
      required final AlertType type,
      final String? analysis,
      required final List<String> takeProfits,
      final String? image,
      final String? imageUrl,
      required final DateTime createdAt,
      required final String createdBy,
      required final bool isPublic,
      final AlertStatus status}) = _$AlertImpl;

  factory _Alert.fromJson(Map<String, dynamic> json) = _$AlertImpl.fromJson;

  @override
  String get id;
  @override
  String? get title;
  @override
  String? get content;
  @override
  String get pair;
  @override
  String get entry;
  @override
  String get stopLoss;
  @override
  AlertType get type;
  @override
  String? get analysis;
  @override
  List<String> get takeProfits;
  @override
  String? get image;
  @override
  String? get imageUrl;
  @override
  DateTime get createdAt;
  @override
  String get createdBy;
  @override
  bool get isPublic;
  @override
  AlertStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
