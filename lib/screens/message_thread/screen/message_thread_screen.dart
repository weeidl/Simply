import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:sms_forward_app/screens/message_thread/cubit/message_thread_cubit.dart';
import 'package:sms_forward_app/screens/message_thread/widget/message_thread_widget.dart';
import 'package:sms_forward_app/screens/messages_list/cubit/messages_cubit.dart';
import 'package:sms_forward_app/screens/widget/app_bar_back_widget.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class MessageThreadScreen extends StatelessWidget {
  final String id;
  final String title;

  const MessageThreadScreen({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessageThreadCubit(
        messagesRepository: MessagesRepository(),
      ),
      child: Scaffold(
        backgroundColor: AppColor.orange,
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              AppBarBackWidget(
                nameScreen: title,
                isLight: false,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: BlocConsumer<MessageThreadCubit, MessageThreadState>(
                    listener: (context, state) async {
                      if (state is MessagesError) {
                        //код выполнения ошибки
                      }
                    },
                    builder: (context, state) {
                      if (state is MessageThreadInitial) {
                        context.read<MessageThreadCubit>().fetch(id, title);
                        context.read<MessagesCubit>().fetch();
                      }
                      if (state is MessageThreadLoaded) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 44),
                            child: ListView.builder(
                              itemCount: state.items.length,
                              shrinkWrap: true,
                              reverse: true,
                              itemBuilder: (context, index) {
                                final message = state.items[index];
                                final bool showTime = index == 0 ||
                                    message.date != state.items[index - 1].date;
                                return Column(
                                  children: [
                                    if (showTime)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 24,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          message.date
                                              .toString(), // This should be formatted as needed
                                          style: AppTextStyle.captionS(
                                            AppColor.grey,
                                          ),
                                        ),
                                      ),
                                    MessageThreadWidget(
                                      message: message.text,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
