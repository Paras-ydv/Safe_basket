// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detected_chemical.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DetectedChemical _$DetectedChemicalFromJson(Map<String, dynamic> json) {
  return _DetectedChemical.fromJson(json);
}

/// @nodoc
mixin _$DetectedChemical {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  RiskLevel get risk => throw _privateConstructorUsedError;

  /// Serializes this DetectedChemical to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectedChemical
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectedChemicalCopyWith<DetectedChemical> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectedChemicalCopyWith<$Res> {
  factory $DetectedChemicalCopyWith(
    DetectedChemical value,
    $Res Function(DetectedChemical) then,
  ) = _$DetectedChemicalCopyWithImpl<$Res, DetectedChemical>;
  @useResult
  $Res call({String id, String name, RiskLevel risk});
}

/// @nodoc
class _$DetectedChemicalCopyWithImpl<$Res, $Val extends DetectedChemical>
    implements $DetectedChemicalCopyWith<$Res> {
  _$DetectedChemicalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectedChemical
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? risk = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            risk: null == risk
                ? _value.risk
                : risk // ignore: cast_nullable_to_non_nullable
                      as RiskLevel,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DetectedChemicalImplCopyWith<$Res>
    implements $DetectedChemicalCopyWith<$Res> {
  factory _$$DetectedChemicalImplCopyWith(
    _$DetectedChemicalImpl value,
    $Res Function(_$DetectedChemicalImpl) then,
  ) = __$$DetectedChemicalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, RiskLevel risk});
}

/// @nodoc
class __$$DetectedChemicalImplCopyWithImpl<$Res>
    extends _$DetectedChemicalCopyWithImpl<$Res, _$DetectedChemicalImpl>
    implements _$$DetectedChemicalImplCopyWith<$Res> {
  __$$DetectedChemicalImplCopyWithImpl(
    _$DetectedChemicalImpl _value,
    $Res Function(_$DetectedChemicalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DetectedChemical
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? risk = null}) {
    return _then(
      _$DetectedChemicalImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        risk: null == risk
            ? _value.risk
            : risk // ignore: cast_nullable_to_non_nullable
                  as RiskLevel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectedChemicalImpl implements _DetectedChemical {
  const _$DetectedChemicalImpl({
    required this.id,
    required this.name,
    required this.risk,
  });

  factory _$DetectedChemicalImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectedChemicalImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final RiskLevel risk;

  @override
  String toString() {
    return 'DetectedChemical(id: $id, name: $name, risk: $risk)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectedChemicalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.risk, risk) || other.risk == risk));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, risk);

  /// Create a copy of DetectedChemical
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectedChemicalImplCopyWith<_$DetectedChemicalImpl> get copyWith =>
      __$$DetectedChemicalImplCopyWithImpl<_$DetectedChemicalImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectedChemicalImplToJson(this);
  }
}

abstract class _DetectedChemical implements DetectedChemical {
  const factory _DetectedChemical({
    required final String id,
    required final String name,
    required final RiskLevel risk,
  }) = _$DetectedChemicalImpl;

  factory _DetectedChemical.fromJson(Map<String, dynamic> json) =
      _$DetectedChemicalImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  RiskLevel get risk;

  /// Create a copy of DetectedChemical
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectedChemicalImplCopyWith<_$DetectedChemicalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
