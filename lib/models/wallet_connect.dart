import 'package:form_builder_validators/form_builder_validators.dart';

/// WalletConnect Methods
abstract class WcMethods {
  /// Get the client to request a list of all accounts in wallet
  static const wRequestAccounts = "qubic_requestAccounts";

  /// Send qubic from an account to a destination address
  static const wSendQubic = "qubic_sendQubic";

  /// Create and broadcast a new transaction either for Qus or SC
  static const wSendTransaction = "qubic_sendTransaction";

  /// Send assets from an account to a destination address
  static const wSendAsset = "qubic_sendAsset";

  /// Sign a transaction
  static const wSignTransaction = "qubic_signTransaction";

  /// Sign a generic message
  static const wSign = "qubic_sign";
}

/// WalletConnect Events
abstract class WcEvents {
  /// The list of accounts has changed
  static const accountsChanged = "accountsChanged";

  /// The amount of tokens in an account has changed
  static const tokenAmountChanged = "tokenAmountChanged";

  /// The amount of qubics in an account has changed
  static const amountChanged = "amountChanged";
}

/// WalletConnect Errors
abstract class WcErrors {
  static const qwUserUnavailable = -32001;
  static const qwTickBecameInPast = -32002;
  static const qwUnexpectedError = -32603;
}

typedef Validator = String? Function(dynamic value);

class WcValidationUtils {
  static void validateField({
    required Map<String, dynamic> map,
    required String fieldName,
    required List<Validator> validators,
  }) {
    final composedValidator = FormBuilderValidators.compose(validators);
    final error = composedValidator(map[fieldName]);
    if (map[fieldName] == null || error != null) {
      throw ArgumentError(error, fieldName);
    }
  }

  static void validateOptionalField({
    required Map<String, dynamic> map,
    required String fieldName,
    required List<Validator> validators,
  }) {
    if (map[fieldName] != null) {
      final composedValidator = FormBuilderValidators.compose(validators);
      final error = composedValidator(map[fieldName]);
      if (error != null) {
        throw ArgumentError(error, fieldName);
      }
    }
  }
}

class WcRequestParameters {
  static const from = "from";
  static const to = "to";
  static const amount = "amount";
  static const tick = "tick";
  static const inputType = "inputType";
  static const payload = "payload";
  static const message = "message";
  static const assetName = "assetName";
  static const issuer = "issuer";
  static const redirectUrl = "redirectUrl";
}
