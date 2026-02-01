import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_state.freezed.dart';

@Freezed(genericArgumentFactories: true)
sealed class Ds<T> with _$Ds<T> {
  const factory Ds.initial() = InitialState;
  const factory Ds.loading() = LoadingState;
  const factory Ds.success(T data) = SuccessState;
  const factory Ds.error(String error) = ErrorState;
}
