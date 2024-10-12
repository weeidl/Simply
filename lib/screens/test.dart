// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> _messages = [];
//
//   // Функция для отправки сообщения на Webhook
//   Future<void> _sendMessage(String message) async {
//     if (message.isEmpty) {
//       return;
//     }
//
//     // Добавляем сообщение пользователя в список сообщений
//     setState(() {
//       _messages.add({'sender': 'user', 'text': message});
//     });
//
//     // URL Webhook для n8n
//     // final url =
//     //     'http://10.0.2.2:5678/webhook/e9282ef9-9c47-4e3f-a3ed-1027091fe1ea'; // Замените на актуальный URL
//
//     try {
//       // Отправка POST-запроса на Webhook
//       final response = await http.post(
//         Uri.http('10.0.2.2:5678',
//             '/webhook/4fcc513c-5bef-49cd-96a5-1c8c360658ca/chat'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'chatInput': message,
//         }),
//       );
//
//       log(response.body);
//       // Проверяем успешность запроса
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         print(responseBody);
//         //   // Добавляем ответ от n8n в список сообщений
//         setState(() {
//           _messages.add({
//             'sender': 'n8n',
//             'text': responseBody['response']['text'] ?? 'Ответ от сервера!',
//           });
//         });
//       } else {
//         setState(() {
//           _messages.add({
//             'sender': 'n8n',
//             'text': 'Ошибка: ${response.statusCode}',
//           });
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _messages.add({'sender': 'n8n', 'text': 'Ошибка: $error'});
//       });
//     }
//
//     // Очищаем поле ввода
//     _controller.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('n8n Webhook Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(8.0),
//               reverse: true, // Сообщения будут показаны снизу вверх
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[_messages.length - 1 - index];
//                 final isUser = message['sender'] == 'user';
//                 return Align(
//                   alignment: isUser
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft, // Выравнивание сообщений
//                   child: Container(
//                     padding: const EdgeInsets.all(10.0),
//                     margin: const EdgeInsets.symmetric(vertical: 5.0),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.blue : Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: Text(
//                       message['text']!,
//                       style: TextStyle(
//                         color: isUser ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Введите сообщение...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage(
//                         _controller.text); // Отправляем сообщение на Webhook
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
