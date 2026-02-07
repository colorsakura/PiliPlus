// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadStatusData {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusData);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatusData()';
}


}

/// @nodoc
class $DownloadStatusDataCopyWith<$Res>  {
$DownloadStatusDataCopyWith(DownloadStatusData _, $Res Function(DownloadStatusData) __);
}


/// Adds pattern-matching-related methods to [DownloadStatusData].
extension DownloadStatusDataPatterns on DownloadStatusData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DownloadStatusData_Pending value)?  pending,TResult Function( DownloadStatusData_Downloading value)?  downloading,TResult Function( DownloadStatusData_Paused value)?  paused,TResult Function( DownloadStatusData_Completed value)?  completed,TResult Function( DownloadStatusData_Failed value)?  failed,TResult Function( DownloadStatusData_Cancelled value)?  cancelled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DownloadStatusData_Pending() when pending != null:
return pending(_that);case DownloadStatusData_Downloading() when downloading != null:
return downloading(_that);case DownloadStatusData_Paused() when paused != null:
return paused(_that);case DownloadStatusData_Completed() when completed != null:
return completed(_that);case DownloadStatusData_Failed() when failed != null:
return failed(_that);case DownloadStatusData_Cancelled() when cancelled != null:
return cancelled(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DownloadStatusData_Pending value)  pending,required TResult Function( DownloadStatusData_Downloading value)  downloading,required TResult Function( DownloadStatusData_Paused value)  paused,required TResult Function( DownloadStatusData_Completed value)  completed,required TResult Function( DownloadStatusData_Failed value)  failed,required TResult Function( DownloadStatusData_Cancelled value)  cancelled,}){
final _that = this;
switch (_that) {
case DownloadStatusData_Pending():
return pending(_that);case DownloadStatusData_Downloading():
return downloading(_that);case DownloadStatusData_Paused():
return paused(_that);case DownloadStatusData_Completed():
return completed(_that);case DownloadStatusData_Failed():
return failed(_that);case DownloadStatusData_Cancelled():
return cancelled(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DownloadStatusData_Pending value)?  pending,TResult? Function( DownloadStatusData_Downloading value)?  downloading,TResult? Function( DownloadStatusData_Paused value)?  paused,TResult? Function( DownloadStatusData_Completed value)?  completed,TResult? Function( DownloadStatusData_Failed value)?  failed,TResult? Function( DownloadStatusData_Cancelled value)?  cancelled,}){
final _that = this;
switch (_that) {
case DownloadStatusData_Pending() when pending != null:
return pending(_that);case DownloadStatusData_Downloading() when downloading != null:
return downloading(_that);case DownloadStatusData_Paused() when paused != null:
return paused(_that);case DownloadStatusData_Completed() when completed != null:
return completed(_that);case DownloadStatusData_Failed() when failed != null:
return failed(_that);case DownloadStatusData_Cancelled() when cancelled != null:
return cancelled(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  pending,TResult Function( double speed,  double? eta)?  downloading,TResult Function()?  paused,TResult Function()?  completed,TResult Function( String error)?  failed,TResult Function()?  cancelled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DownloadStatusData_Pending() when pending != null:
return pending();case DownloadStatusData_Downloading() when downloading != null:
return downloading(_that.speed,_that.eta);case DownloadStatusData_Paused() when paused != null:
return paused();case DownloadStatusData_Completed() when completed != null:
return completed();case DownloadStatusData_Failed() when failed != null:
return failed(_that.error);case DownloadStatusData_Cancelled() when cancelled != null:
return cancelled();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  pending,required TResult Function( double speed,  double? eta)  downloading,required TResult Function()  paused,required TResult Function()  completed,required TResult Function( String error)  failed,required TResult Function()  cancelled,}) {final _that = this;
switch (_that) {
case DownloadStatusData_Pending():
return pending();case DownloadStatusData_Downloading():
return downloading(_that.speed,_that.eta);case DownloadStatusData_Paused():
return paused();case DownloadStatusData_Completed():
return completed();case DownloadStatusData_Failed():
return failed(_that.error);case DownloadStatusData_Cancelled():
return cancelled();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  pending,TResult? Function( double speed,  double? eta)?  downloading,TResult? Function()?  paused,TResult? Function()?  completed,TResult? Function( String error)?  failed,TResult? Function()?  cancelled,}) {final _that = this;
switch (_that) {
case DownloadStatusData_Pending() when pending != null:
return pending();case DownloadStatusData_Downloading() when downloading != null:
return downloading(_that.speed,_that.eta);case DownloadStatusData_Paused() when paused != null:
return paused();case DownloadStatusData_Completed() when completed != null:
return completed();case DownloadStatusData_Failed() when failed != null:
return failed(_that.error);case DownloadStatusData_Cancelled() when cancelled != null:
return cancelled();case _:
  return null;

}
}

}

/// @nodoc


class DownloadStatusData_Pending extends DownloadStatusData {
  const DownloadStatusData_Pending(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusData_Pending);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatusData.pending()';
}


}




/// @nodoc


class DownloadStatusData_Downloading extends DownloadStatusData {
  const DownloadStatusData_Downloading({required this.speed, this.eta}): super._();
  

 final  double speed;
 final  double? eta;

/// Create a copy of DownloadStatusData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadStatusData_DownloadingCopyWith<DownloadStatusData_Downloading> get copyWith => _$DownloadStatusData_DownloadingCopyWithImpl<DownloadStatusData_Downloading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusData_Downloading&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.eta, eta) || other.eta == eta));
}


@override
int get hashCode => Object.hash(runtimeType,speed,eta);

@override
String toString() {
  return 'DownloadStatusData.downloading(speed: $speed, eta: $eta)';
}


}

/// @nodoc
abstract mixin class $DownloadStatusData_DownloadingCopyWith<$Res> implements $DownloadStatusDataCopyWith<$Res> {
  factory $DownloadStatusData_DownloadingCopyWith(DownloadStatusData_Downloading value, $Res Function(DownloadStatusData_Downloading) _then) = _$DownloadStatusData_DownloadingCopyWithImpl;
@useResult
$Res call({
 double speed, double? eta
});




}
/// @nodoc
class _$DownloadStatusData_DownloadingCopyWithImpl<$Res>
    implements $DownloadStatusData_DownloadingCopyWith<$Res> {
  _$DownloadStatusData_DownloadingCopyWithImpl(this._self, this._then);

  final DownloadStatusData_Downloading _self;
  final $Res Function(DownloadStatusData_Downloading) _then;

/// Create a copy of DownloadStatusData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? speed = null,Object? eta = freezed,}) {
  return _then(DownloadStatusData_Downloading(
speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,eta: freezed == eta ? _self.eta : eta // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc


class DownloadStatusData_Paused extends DownloadStatusData {
  const DownloadStatusData_Paused(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusData_Paused);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatusData.paused()';
}


}




/// @nodoc


class DownloadStatusData_Completed extends DownloadStatusData {
  const DownloadStatusData_Completed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusData_Completed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatusData.completed()';
}


}




/// @nodoc


class DownloadStatusData_Failed extends DownloadStatusData {
  const DownloadStatusData_Failed({required this.error}): super._();
  

 final  String error;

/// Create a copy of DownloadStatusData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadStatusData_FailedCopyWith<DownloadStatusData_Failed> get copyWith => _$DownloadStatusData_FailedCopyWithImpl<DownloadStatusData_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusData_Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'DownloadStatusData.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $DownloadStatusData_FailedCopyWith<$Res> implements $DownloadStatusDataCopyWith<$Res> {
  factory $DownloadStatusData_FailedCopyWith(DownloadStatusData_Failed value, $Res Function(DownloadStatusData_Failed) _then) = _$DownloadStatusData_FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$DownloadStatusData_FailedCopyWithImpl<$Res>
    implements $DownloadStatusData_FailedCopyWith<$Res> {
  _$DownloadStatusData_FailedCopyWithImpl(this._self, this._then);

  final DownloadStatusData_Failed _self;
  final $Res Function(DownloadStatusData_Failed) _then;

/// Create a copy of DownloadStatusData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(DownloadStatusData_Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DownloadStatusData_Cancelled extends DownloadStatusData {
  const DownloadStatusData_Cancelled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadStatusData_Cancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadStatusData.cancelled()';
}


}




// dart format on
