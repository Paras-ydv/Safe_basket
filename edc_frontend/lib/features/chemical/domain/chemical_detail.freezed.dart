// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chemical_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChemicalDetail _$ChemicalDetailFromJson(Map<String, dynamic> json) {
  return _ChemicalDetail.fromJson(json);
}

/// @nodoc
mixin _$ChemicalDetail {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  RiskLevel get risk => throw _privateConstructorUsedError;
  String get chemicalClass => throw _privateConstructorUsedError;
  List<String> get healthEffects => throw _privateConstructorUsedError;
  List<ExposureRoute> get exposureRoutes => throw _privateConstructorUsedError;
  String get regulatoryStatus => throw _privateConstructorUsedError;

  /// Serializes this ChemicalDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChemicalDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChemicalDetailCopyWith<ChemicalDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChemicalDetailCopyWith<$Res> {
  factory $ChemicalDetailCopyWith(
    ChemicalDetail value,
    $Res Function(ChemicalDetail) then,
  ) = _$ChemicalDetailCopyWithImpl<$Res, ChemicalDetail>;
  @useResult
  $Res call({
    String id,
    String name,
    RiskLevel risk,
    String chemicalClass,
    List<String> healthEffects,
    List<ExposureRoute> exposureRoutes,
    String regulatoryStatus,
  });
}

/// @nodoc
class _$ChemicalDetailCopyWithImpl<$Res, $Val extends ChemicalDetail>
    implements $ChemicalDetailCopyWith<$Res> {
  _$ChemicalDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChemicalDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? risk = null,
    Object? chemicalClass = null,
    Object? healthEffects = null,
    Object? exposureRoutes = null,
    Object? regulatoryStatus = null,
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
            chemicalClass: null == chemicalClass
                ? _value.chemicalClass
                : chemicalClass // ignore: cast_nullable_to_non_nullable
                      as String,
            healthEffects: null == healthEffects
                ? _value.healthEffects
                : healthEffects // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            exposureRoutes: null == exposureRoutes
                ? _value.exposureRoutes
                : exposureRoutes // ignore: cast_nullable_to_non_nullable
                      as List<ExposureRoute>,
            regulatoryStatus: null == regulatoryStatus
                ? _value.regulatoryStatus
                : regulatoryStatus // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChemicalDetailImplCopyWith<$Res>
    implements $ChemicalDetailCopyWith<$Res> {
  factory _$$ChemicalDetailImplCopyWith(
    _$ChemicalDetailImpl value,
    $Res Function(_$ChemicalDetailImpl) then,
  ) = __$$ChemicalDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    RiskLevel risk,
    String chemicalClass,
    List<String> healthEffects,
    List<ExposureRoute> exposureRoutes,
    String regulatoryStatus,
  });
}

/// @nodoc
class __$$ChemicalDetailImplCopyWithImpl<$Res>
    extends _$ChemicalDetailCopyWithImpl<$Res, _$ChemicalDetailImpl>
    implements _$$ChemicalDetailImplCopyWith<$Res> {
  __$$ChemicalDetailImplCopyWithImpl(
    _$ChemicalDetailImpl _value,
    $Res Function(_$ChemicalDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChemicalDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? risk = null,
    Object? chemicalClass = null,
    Object? healthEffects = null,
    Object? exposureRoutes = null,
    Object? regulatoryStatus = null,
  }) {
    return _then(
      _$ChemicalDetailImpl(
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
        chemicalClass: null == chemicalClass
            ? _value.chemicalClass
            : chemicalClass // ignore: cast_nullable_to_non_nullable
                  as String,
        healthEffects: null == healthEffects
            ? _value._healthEffects
            : healthEffects // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        exposureRoutes: null == exposureRoutes
            ? _value._exposureRoutes
            : exposureRoutes // ignore: cast_nullable_to_non_nullable
                  as List<ExposureRoute>,
        regulatoryStatus: null == regulatoryStatus
            ? _value.regulatoryStatus
            : regulatoryStatus // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChemicalDetailImpl implements _ChemicalDetail {
  const _$ChemicalDetailImpl({
    required this.id,
    required this.name,
    required this.risk,
    required this.chemicalClass,
    final List<String> healthEffects = const <String>[],
    final List<ExposureRoute> exposureRoutes = const <ExposureRoute>[],
    required this.regulatoryStatus,
  }) : _healthEffects = healthEffects,
       _exposureRoutes = exposureRoutes;

  factory _$ChemicalDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChemicalDetailImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final RiskLevel risk;
  @override
  final String chemicalClass;
  final List<String> _healthEffects;
  @override
  @JsonKey()
  List<String> get healthEffects {
    if (_healthEffects is EqualUnmodifiableListView) return _healthEffects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_healthEffects);
  }

  final List<ExposureRoute> _exposureRoutes;
  @override
  @JsonKey()
  List<ExposureRoute> get exposureRoutes {
    if (_exposureRoutes is EqualUnmodifiableListView) return _exposureRoutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exposureRoutes);
  }

  @override
  final String regulatoryStatus;

  @override
  String toString() {
    return 'ChemicalDetail(id: $id, name: $name, risk: $risk, chemicalClass: $chemicalClass, healthEffects: $healthEffects, exposureRoutes: $exposureRoutes, regulatoryStatus: $regulatoryStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChemicalDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.risk, risk) || other.risk == risk) &&
            (identical(other.chemicalClass, chemicalClass) ||
                other.chemicalClass == chemicalClass) &&
            const DeepCollectionEquality().equals(
              other._healthEffects,
              _healthEffects,
            ) &&
            const DeepCollectionEquality().equals(
              other._exposureRoutes,
              _exposureRoutes,
            ) &&
            (identical(other.regulatoryStatus, regulatoryStatus) ||
                other.regulatoryStatus == regulatoryStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    risk,
    chemicalClass,
    const DeepCollectionEquality().hash(_healthEffects),
    const DeepCollectionEquality().hash(_exposureRoutes),
    regulatoryStatus,
  );

  /// Create a copy of ChemicalDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChemicalDetailImplCopyWith<_$ChemicalDetailImpl> get copyWith =>
      __$$ChemicalDetailImplCopyWithImpl<_$ChemicalDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChemicalDetailImplToJson(this);
  }
}

abstract class _ChemicalDetail implements ChemicalDetail {
  const factory _ChemicalDetail({
    required final String id,
    required final String name,
    required final RiskLevel risk,
    required final String chemicalClass,
    final List<String> healthEffects,
    final List<ExposureRoute> exposureRoutes,
    required final String regulatoryStatus,
  }) = _$ChemicalDetailImpl;

  factory _ChemicalDetail.fromJson(Map<String, dynamic> json) =
      _$ChemicalDetailImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  RiskLevel get risk;
  @override
  String get chemicalClass;
  @override
  List<String> get healthEffects;
  @override
  List<ExposureRoute> get exposureRoutes;
  @override
  String get regulatoryStatus;

  /// Create a copy of ChemicalDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChemicalDetailImplCopyWith<_$ChemicalDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
