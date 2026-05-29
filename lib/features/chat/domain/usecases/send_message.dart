import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class SendMessage extends UseCase<void, SendMessageParams> {
  final ChatRepository repository;
  SendMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(SendMessageParams params) {
    return repository.sendMessage(
      senderId: params.senderId,
      receiverId: params.receiverId,
      text: params.text,
      imageUrl: params.imageUrl,
      localId: params.localId,
      adId: params.adId,
      adTitle: params.adTitle,
      adImageUrl: params.adImageUrl,
      adPrice: params.adPrice,
    );
  }
}

class SendImageMessage extends UseCase<void, SendImageParams> {
  final ChatRepository repository;
  SendImageMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(SendImageParams params) async {
    final uploadResult = await repository.uploadChatImage(
      chatId: params.chatId,
      image: params.image,
      onProgress: params.onProgress,
    );
    return uploadResult.fold(
          (failure) => Left(failure),
          (imageUrl) => repository.sendMessage(
        senderId: params.senderId,
        receiverId: params.receiverId,
        text: '📷 Photo',
        imageUrl: imageUrl,
        adId: params.adId,
        adTitle: params.adTitle,
        adImageUrl: params.adImageUrl,
        adPrice: params.adPrice,
      ),
    );
  }
}

class SendMessageParams {
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final String? localId;
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  const SendMessageParams({
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    this.localId,
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
  });
}

class SendImageParams {
  final String senderId;
  final String receiverId;
  final String chatId;
  final String pendingId;
  final File image;
  final void Function(double)? onProgress;
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  const SendImageParams({
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    this.onProgress,
    required this.image,
    required this.pendingId,
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
  });
}