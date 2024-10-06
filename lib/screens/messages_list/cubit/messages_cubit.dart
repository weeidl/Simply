import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepository messagesRepository;

  MessagesCubit({required this.messagesRepository}) : super(MessagesInitial());

  Future<void> fetch() async {
    emit(MessagesLoading());

    // try {
    final response = await messagesRepository.fetchMessages();

    // state is MessagesLoaded
    emit(MessagesLoaded(items: response));
    // } catch (e) {
    //   emit(MessagesError(message: e.toString()));
    // }
  }
}
