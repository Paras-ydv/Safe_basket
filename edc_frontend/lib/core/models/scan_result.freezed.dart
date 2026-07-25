// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScanResult _$ScanResultFromJson(Map<String, dynamic> json) {
  return _ScanResult.fromJson(json);
}

/// @nodoc
mixin _$ScanResult {
  String get scanId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  DateTime get scannedAt => throw _privateConstructorUsedError;
  RiskLevel get overallRisk => throw _privateConstructorUsedError;
  List<DetectedChemical> get detectedChemicals =>
      throw _privateConstructorUsedError;
  String? get productMeta => throw _privateConstructorUsedError; // batch / size
  String? get disclaimer => throw _privateConstructorUsedError;

  /// Serializes this ScanResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScanResultCopyWith<ScanResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanResultCopyWith<$Res> {
  factory $ScanResultCopyWith(
    ScanResult value,
    $Res Function(ScanResult) then,
  ) = _$ScanResultCopyWithImpl<$Res, ScanResult>;
  @useResult
  $Res call({
    String scanId,
    String productName,
    DateTime scannedAt,
    RiskLevel overallRisk,
    List<DetectedChemical> detectedChemicals,
    String? productMeta,
    String? disclaimer,
  });
}

/// @nodoc
class _$ScanResultCopyWithImpl<$Res, $Val extends ScanResult>
    implements $ScanResultCopyWith<$Res> {
  _$ScanResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scanId = null,
    Object? productName = null,
    Object? scannedAt = null,
    Object? overallRisk = null,
    Object? detectedChemicals = null,
    Object? productMeta = freezed,
    Object? disclaimer = freezed,
  }) {
    return _then(
      _value.copyWith(
            scanId: null == scanId
                ? _value.scanId
                : scanId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            scannedAt: null == scannedAt
                ? _value.scannedAt
                : scannedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            overallRisk: null == overallRisk
                ? _value.overallRisk
                : overallRisk // ignore: cast_nullable_to_non_nullable
                      as RiskLevel,
            detectedChemicals: null == detectedChemicals
                ? _value.detectedChemicals
                : detectedChemicals // ignore: cast_nullable_to_non_nullable
                      as List<DetectedChemical>,
            productMeta: freezed == productMeta
                ? _value.productMeta
                : productMeta // ignore: cast_nullable_to_non_nullable
                      as String?,
            disclaimer: freezed == disclaimer
                ? _value.disclaimer
                : disclaimer // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScanResultImplCopyWith<$Res>
    implements $ScanResultCopyWith<$Res> {
  factory _$$ScanResultImplCopyWith(
    _$ScanResultImpl value,
    $Res Function(_$ScanResultImpl) then,
  ) = __$$ScanResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String scanId,
    String productName,
    DateTime scannedAt,
    RiskLevel overallRisk,
    List<DetectedChemical> detectedChemicals,
    String? productMeta,
    String? disclaimer,
  });
}

/// @nodoc
class __$$ScanResultImplCopyWithImpl<$Res>
    extends _$ScanResultCopyWithImpl<$Res, _$ScanResultImpl>
    implements _$$ScanResultImplCopyWith<$Res> {
  __$$ScanResultImplCopyWithImpl(
    _$ScanResultImpl _value,
    $Res Function(_$ScanResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scanId = null,
    Object? productName = null,
    Object? scannedAt = null,
    Object? overallRisk = null,
    Object? detectedChemicals = null,
    Object? productMeta = freezed,
    Object? disclaimer = freezed,
  }) {
    return _then(
      _$ScanResultImpl(
        scanId: null == scanId
            ? _value.scanId
            : scanId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        scannedAt: null == scannedAt
            ? _value.scannedAt
            : scannedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        overallRisk: null == overallRisk
            ? _value.overallRisk
            : overallRisk // ignore: cast_nullable_to_non_nullable
                  as RiskLevel,
        detectedChemicals: null == detectedChemicals
            ? _value._detectedChemicals
            : detectedChemicals // ignore: cast_nullable_to_non_nullable
                  as List<DetectedChemical>,
        productMeta: freezed == productMeta
            ? _value.productMeta
            : productMeta // ignore: cast_nullable_to_non_nullable
                  as String?,
        disclaimer: freezed == disclaimer
            ? _value.disclaimer
            : disclaimer // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScanResultImpl implements _ScanResult {
  const _$ScanResultImpl({
    required this.scanId,
    required this.productName,
    required this.scannedAt,
    required this.overallRisk,
    final List<DetectedChemical> detectedChemicals = const <DetectedChemical>[],
    this.productMeta,
    this.disclaimer,
  }) : _detectedChemicals = detectedChemicals;

  factory _$ScanResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanResultImplFromJson(json);

  @override
  final String scanId;
  @override
  final String productName;
  @override
  final DateTime scannedAt;
  @override
  final RiskLevel overallRisk;
  final List<DetectedChemical> _detectedChemicals;
  @override
  @JsonKey()
  List<DetectedChemical> get detectedChemicals {
    if (_detectedChemicals is EqualUnmodifiableListView)
      return _detectedChemicals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detectedChemicals);
  }

  @override
  final String? productMeta;
  // batch / size
  @override
  final String? disclaimer;

  @override
  String toString() {
    return 'ScanResult(scanId: $scanId, productName: $productName, scannedAt: $scannedAt, overallRisk: $overallRisk, detectedChemicals: $detectedChemicals, productMeta: $productMeta, disclaimer: $disclaimer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanResultImpl &&
            (identical(other.scanId, scanId) || other.scanId == scanId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.scannedAt, scannedAt) ||
                other.scannedAt == scannedAt) &&
            (identical(other.overallRisk, overallRisk) ||
                other.overallRisk == overallRisk) &&
            const DeepCollectionEquality().equals(
              other._detectedChemicals,
              _detectedChemicals,
            ) &&
            (identical(other.productMeta, productMeta) ||
                other.productMeta == productMeta) &&
            (identical(other.disclaimer, disclaimer) ||
                other.disclaimer == disclaimer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    scanId,
    productName,
    scannedAt,
    overallRisk,
    const DeepCollectionEquality().hash(_detectedChemicals),
    productMeta,
    disclaimer,
  );

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanResultImplCopyWith<_$ScanResultImpl> get copyWith =>
      __$$ScanResultImplCopyWithImpl<_$ScanResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanResultImplToJson(this);
  }
}

abstract class _ScanResult implements ScanResult {
  const factory _ScanResult({
    required final String scanId,
    required final String productName,
    required final DateTime scannedAt,
    required final RiskLevel overallRisk,
    final List<DetectedChemical> detectedChemicals,
    final String? productMeta,
    final String? disclaimer,
  }) = _$ScanResultImpl;

  factory _ScanResult.fromJson(Map<String, dynamic> json) =
      _$ScanResultImpl.fromJson;

  @override
  String get scanId;
  @override
  String get productName;
  @override
  DateTime get scannedAt;
  @override
  RiskLevel get overallRisk;
  @override
  List<DetectedChemical> get detectedChemicals;
  @override
  String? get productMeta; // batch / size
  @override
  String? get disclaimer;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScanResultImplCopyWith<_$ScanResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
