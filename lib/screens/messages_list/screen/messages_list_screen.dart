import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sms_forward_app/bloc/update_message_stream.dart';
import 'package:sms_forward_app/screens/message_thread/screen/message_thread_screen.dart';
import 'package:sms_forward_app/screens/messages_list/cubit/messages_cubit.dart';
import 'package:sms_forward_app/screens/messages_list/widget/messages_list_widget.dart';
import 'package:sms_forward_app/screens/widget/app_bar_widget.dart';
import 'package:sms_forward_app/themes/colors.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  StreamSubscription? _setTabStream;

  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEE HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.orange,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const AppBarWidget(
              nameScreen: 'Messages',
              isLight: false,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24,
                ),
                decoration: const BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: BlocConsumer<MessagesCubit, MessagesState>(
                  listener: (context, state) async {
                    if (state is MessagesError) {
                      //код выполнения ошибки
                    }
                  },
                  builder: (context, state) {
                    if (state is MessagesInitial) {
                      context.read<MessagesCubit>().fetch();
                      _setTabStream =
                          UpdateMessageStream.stream.listen((event) {
                        context.read<MessagesCubit>().fetch();
                      });
                    }
                    if (state is MessagesLoaded) {
                      return ListView.builder(
                        itemCount: state.items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final message = state.items[index];
                          return InkWell(
                            onTap: () async {
                              // DocumentReference userDocument = firestore
                              //     .collection('messages')
                              //     .doc('userId');
                              //
                              // // непрочитанные сообщения
                              //
                              // // for (QueryDocumentSnapshot messageDoc in unreadMessages.docs) {
                              // //   await messageDoc.reference.update({'isRead': true});
                              // // }
                              // //
                              // // await userDocument.update({'unreadMessagesCount': 0});
                              //
                              // // непрочитанные сообщения
                              //
                              // await userDocument.set(
                              //   {
                              //     'unreadMessagesCount':
                              //         FieldValue.increment(1),
                              //     'lastMessage': 'lastMessage',
                              //     'lastMessageDate': DateTime.now(),
                              //     'avatar': 'avatarUrl',
                              //   },
                              //   SetOptions(merge: true),
                              // );
                              //
                              // CollectionReference messagesCollection =
                              //     userDocument.collection('DenizBank');
                              //
                              // Message message = Message(
                              //   'Привет, как дела?',
                              //   DateTime.now(),
                              // );
                              //
                              // // Проверка сообщения на наличие 5-6 цифрового кода
                              //
                              // // RegExp regExp = RegExp(r"\b\d{5,6}\b");
                              // // Match? match = regExp.firstMatch(
                              // //     "JFN aksnfas klasnfsdjknf ;laskf kndsk: 544532 code it this");
                              // //
                              // // String? code;
                              // // if (match != null) {
                              // //   code = match.group(0);
                              // // }
                              //
                              // // Проверка сообщения на наличие 5-6 цифрового кода
                              //
                              // await messagesCollection.add(
                              //   {
                              //     'message': message.text,
                              //     'date': DateTime.now(),
                              //     'isRead': false,
                              //     // 'code': code,
                              //   },
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return MessageThreadScreen(
                                      id: message.id,
                                      title: message.title,
                                    );
                                  },
                                ),
                              );
                            },
                            child: MessagesWidget(
                              imagePath: 'path_to_your_image.jpg',
                              title: message.title,
                              message: message.lastMessage,
                              time: formatDateTime(message.lastMessageDate),
                              notificationCount:
                                  message.unreadMessagesCount == 0
                                      ? null
                                      : message.unreadMessagesCount,
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _setTabStream?.cancel();
    super.dispose();
  }
}
