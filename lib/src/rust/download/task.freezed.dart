// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadEventType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEventType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadEventType()';
}


}

/// @nodoc
class $DownloadEventTypeCopyWith<$Res>  {
$DownloadEventTypeCopyWith(DownloadEventType _, $Res Function(DownloadEventType) __);
}


/// Adds pattern-matching-related methods to [DownloadEventType].
extension DownloadEventTypePatterns on DownloadEventType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DownloadEventType_Progress value)?  progress,TResult Function( DownloadEventType_Paused value)?  paused,TResult Function( DownloadEventType_Completed value)?  completed,TResult Function( DownloadEventType_Failed value)?  failed,TResult Function( DownloadEventType_Cancelled value)?  cancelled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DownloadEventType_Progress() when progress != null:
return progress(_that);case DownloadEventType_Paused() when paused != null:
return paused(_that);case DownloadEventType_Completed() when completed != null:
return completed(_that);case DownloadEventType_Failed() when failed != null:
return failed(_that);case DownloadEventType_Cancelled() when cancelled != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DownloadEventType_Progress value)  progress,required TResult Function( DownloadEventType_Paused value)  paused,required TResult Function( DownloadEventType_Completed value)  completed,required TResult Function( DownloadEventType_Failed value)  failed,required TResult Function( DownloadEventType_Cancelled value)  cancelled,}){
final _that = this;
switch (_that) {
case DownloadEventType_Progress():
return progress(_that);case DownloadEventType_Paused():
return paused(_that);case DownloadEventType_Completed():
return completed(_that);case DownloadEventType_Failed():
return failed(_that);case DownloadEventType_Cancelled():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DownloadEventType_Progress value)?  progress,TResult? Function( DownloadEventType_Paused value)?  paused,TResult? Function( DownloadEventType_Completed value)?  completed,TResult? Function( DownloadEventType_Failed value)?  failed,TResult? Function( DownloadEventType_Cancelled value)?  cancelled,}){
final _that = this;
switch (_that) {
case DownloadEventType_Progress() when progress != null:
return progress(_that);case DownloadEventType_Paused() when paused != null:
return paused(_that);case DownloadEventType_Completed() when completed != null:
return completed(_that);case DownloadEventType_Failed() when failed != null:
return failed(_that);case DownloadEventType_Cancelled() when cancelled != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BigInt downloaded,  BigInt total,  double speed)?  progress,TResult Function()?  paused,TResult Function()?  completed,TResult Function( String error)?  failed,TResult Function()?  cancelled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DownloadEventType_Progress() when progress != null:
return progress(_that.downloaded,_that.total,_that.speed);case DownloadEventType_Paused() when paused != null:
return paused();case DownloadEventType_Completed() when completed != null:
return completed();case DownloadEventType_Failed() when failed != null:
return failed(_that.error);case DownloadEventType_Cancelled() when cancelled != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BigInt downloaded,  BigInt total,  double speed)  progress,required TResult Function()  paused,required TResult Function()  completed,required TResult Function( String error)  failed,required TResult Function()  cancelled,}) {final _that = this;
switch (_that) {
case DownloadEventType_Progress():
return progress(_that.downloaded,_that.total,_that.speed);case DownloadEventType_Paused():
return paused();case DownloadEventType_Completed():
return completed();case DownloadEventType_Failed():
return failed(_that.error);case DownloadEventType_Cancelled():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BigInt downloaded,  BigInt total,  double speed)?  progress,TResult? Function()?  paused,TResult? Function()?  completed,TResult? Function( String error)?  failed,TResult? Function()?  cancelled,}) {final _that = this;
switch (_that) {
case DownloadEventType_Progress() when progress != null:
return progress(_that.downloaded,_that.total,_that.speed);case DownloadEventType_Paused() when paused != null:
return paused();case DownloadEventType_Completed() when completed != null:
return completed();case DownloadEventType_Failed() when failed != null:
return failed(_that.error);case DownloadEventType_Cancelled() when cancelled != null:
return cancelled();case _:
  return null;

}
}

}

/// @nodoc


class DownloadEventType_Progress extends DownloadEventType {
  const DownloadEventType_Progress({required this.downloaded, required this.total, required this.speed}): super._();
  

 final  BigInt downloaded;
 final  BigInt total;
 final  double speed;

/// Create a copy of DownloadEventType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadEventType_ProgressCopyWith<DownloadEventType_Progress> get copyWith => _$DownloadEventType_ProgressCopyWithImpl<DownloadEventType_Progress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEventType_Progress&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.total, total) || other.total == total)&&(identical(other.speed, speed) || other.speed == speed));
}


@override
int get hashCode => Object.hash(runtimeType,downloaded,total,speed);

@override
String toString() {
  return 'DownloadEventType.progress(downloaded: $downloaded, total: $total, speed: $speed)';
}


}

/// @nodoc
abstract mixin class $DownloadEventType_ProgressCopyWith<$Res> implements $DownloadEventTypeCopyWith<$Res> {
  factory $DownloadEventType_ProgressCopyWith(DownloadEventType_Progress value, $Res Function(DownloadEventType_Progress) _then) = _$DownloadEventType_ProgressCopyWithImpl;
@useResult
$Res call({
 BigInt downloaded, BigInt total, double speed
});




}
/// @nodoc
class _$DownloadEventType_ProgressCopyWithImpl<$Res>
    implements $DownloadEventType_ProgressCopyWith<$Res> {
  _$DownloadEventType_ProgressCopyWithImpl(this._self, this._then);

  final DownloadEventType_Progress _self;
  final $Res Function(DownloadEventType_Progress) _then;

/// Create a copy of DownloadEventType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? downloaded = null,Object? total = null,Object? speed = null,}) {
  return _then(DownloadEventType_Progress(
downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as BigInt,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as BigInt,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class DownloadEventType_Paused extends DownloadEventType {
  const DownloadEventType_Paused(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEventType_Paused);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadEventType.paused()';
}


}




/// @nodoc


class DownloadEventType_Completed extends DownloadEventType {
  const DownloadEventType_Completed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEventType_Completed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadEventType.completed()';
}


}




/// @nodoc


class DownloadEventType_Failed extends DownloadEventType {
  const DownloadEventType_Failed({required this.error}): super._();
  

 final  String error;

/// Create a copy of DownloadEventType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadEventType_FailedCopyWith<DownloadEventType_Failed> get copyWith => _$DownloadEventType_FailedCopyWithImpl<DownloadEventType_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEventType_Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'DownloadEventType.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $DownloadEventType_FailedCopyWith<$Res> implements $DownloadEventTypeCopyWith<$Res> {
  factory $DownloadEventType_FailedCopyWith(DownloadEventType_Failed value, $Res Function(DownloadEventType_Failed) _then) = _$DownloadEventType_FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$DownloadEventType_FailedCopyWithImpl<$Res>
    implements $DownloadEventType_FailedCopyWith<$Res> {
  _$DownloadEventType_FailedCopyWithImpl(this._self, this._then);

  final DownloadEventType_Failed _self;
  final $Res Function(DownloadEventType_Failed) _then;

/// Create a copy of DownloadEventType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(DownloadEventType_Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DownloadEventType_Cancelled extends DownloadEventType {
  const DownloadEventType_Cancelled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEventType_Cancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DownloadEventType.cancelled()';
}


}




// dart format on
