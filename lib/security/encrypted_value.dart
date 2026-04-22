import 'package:equatable/equatable.dart';

class EncryptedValue extends Equatable {
  final String cipherText;
  final String nonce;
  final String mac;

  const EncryptedValue({
    required this.cipherText,
    required this.nonce,
    required this.mac,
  });

  factory EncryptedValue.fromJson(Map<String, dynamic> json) {
    return EncryptedValue(
      cipherText: json['cipher_text']?.toString() ?? '',
      nonce: json['nonce']?.toString() ?? '',
      mac: json['mac']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cipher_text': cipherText,
      'nonce': nonce,
      'mac': mac,
    };
  }

  @override
  List<Object?> get props => [cipherText, nonce, mac];
}
