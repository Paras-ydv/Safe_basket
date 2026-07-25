// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alternative.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Alternative _$AlternativeFromJson(Map<String, dynamic> json) {
  return _Alternative.fromJson(json);
}

/// @nodoc
mixin _$Alternative {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  RiskLevel get risk => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this Alternative to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Alternative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlternativeCopyWith<Alternative> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlternativeCopyWith<$Res> {
  factory $AlternativeCopyWith(
    Alternative value,
    $Res Function(Alternative) then,
  ) = _$AlternativeCopyWithImpl<$Res, Alternative>;
  @useResult
  $Res call({String id, String name, RiskLevel risk, String? note});
}

/// @nodoc
class _$AlternativeCopyWithImpl<$Res, $Val extends Alternative>
    implements $AlternativeCopyWith<$Res> {
  _$AlternativeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Alternative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? risk = null,
    Object? note = freezed,
  }) {
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
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlternativeImplCopyWith<$Res>
    implements $AlternativeCopyWith<$Res> {
  factory _$$AlternativeImplCopyWith(
    _$AlternativeImpl value,
    $Res Function(_$AlternativeImpl) then,
  ) = __$$AlternativeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, RiskLevel risk, String? note});
}

/// @nodoc
class __$$AlternativeImplCopyWithImpl<$Res>
    extends _$AlternativeCopyWithImpl<$Res, _$AlternativeImpl>
    implements _$$AlternativeImplCopyWith<$Res> {
  __$$AlternativeImplCopyWithImpl(
    _$AlternativeImpl _value,
    $Res Function(_$AlternativeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Alternative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? risk = null,
    Object? note = freezed,
  }) {
    return _then(
      _$AlternativeImpl(
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
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlternativeImpl implements _Alternative {
  const _$AlternativeImpl({
    required this.id,
    required this.name,
    required this.risk,
    this.note,
  });

  factory _$AlternativeImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlternativeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final RiskLevel risk;
  @override
  final String? note;

  @override
  String toString() {
    return 'Alternative(id: $id, name: $name, risk: $risk, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlternativeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.risk, risk) || other.risk == risk) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, risk, note);

  /// Create a copy of Alternative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlternativeImplCopyWith<_$AlternativeImpl> get copyWith =>
      __$$AlternativeImplCopyWithImpl<_$AlternativeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlternativeImplToJson(this);
  }
}

abstract class _Alternative implements Alternative {
  const factory _Alternative({
    required final String id,
    required final String name,
    required final RiskLevel risk,
    final String? note,
  }) = _$AlternativeImpl;

  factory _Alternative.fromJson(Map<String, dynamic> json) =
      _$AlternativeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  RiskLevel get risk;
  @override
  String? get note;

  /// Create a copy of Alternative
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlternativeImplCopyWith<_$AlternativeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
