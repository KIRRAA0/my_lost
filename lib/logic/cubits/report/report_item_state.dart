import 'package:equatable/equatable.dart';

abstract class ReportItemState extends Equatable {
  const ReportItemState();

  @override
  List<Object?> get props => [];
}

class ReportItemInitial extends ReportItemState {}

class ReportItemLoading extends ReportItemState {
  final String? loadingMessage;

  const ReportItemLoading({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

class ImageUploading extends ReportItemState {
  final int progress;
  final String message;

  const ImageUploading({
    required this.progress,
    this.message = 'Uploading image...',
  });

  @override
  List<Object?> get props => [progress, message];
}

class ImageUploadSuccess extends ReportItemState {
  final String imageUrl;

  const ImageUploadSuccess({required this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

class ImageUploadError extends ReportItemState {
  final String message;

  const ImageUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReportItemSuccess extends ReportItemState {
  final String message;
  final String? itemId;

  const ReportItemSuccess({
    required this.message,
    this.itemId,
  });

  @override
  List<Object?> get props => [message, itemId];
}

class ReportItemError extends ReportItemState {
  final String message;
  final String? errorCode;

  const ReportItemError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class ReportItemValidationError extends ReportItemState {
  final Map<String, String> errors;

  const ReportItemValidationError({required this.errors});

  @override
  List<Object?> get props => [errors];
}