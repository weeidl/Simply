import 'package:equatable/equatable.dart';
import 'package:simply/security/encrypted_value.dart';

export 'encrypted_value.dart';

class KeyEnvelope extends Equatable {
  final String salt;
  final EncryptedValue wrappedKey;
  final int iterations;
  final int version;

  const KeyEnvelope({
    required this.salt,
    required this.wrappedKey,
    this.iterations = 120000,
    this.version = 1,
  });

  factory KeyEnvelope.fromJson(Map<String, dynamic> json) {
    return KeyEnvelope(
      salt: json['salt']?.toString() ?? '',
      wrappedKey: EncryptedValue.fromJson(
        Map<String, dynamic>.from(
          json['wrapped_key'] as Map<dynamic, dynamic>? ?? const {},
        ),
      ),
      iterations: (json['iterations'] as num?)?.toInt() ?? 120000,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salt': salt,
      'wrapped_key': wrappedKey.toJson(),
      'iterations': iterations,
      'version': version,
    };
  }

  @override
  List<Object?> get props => [salt, wrappedKey, iterations, version];
}
