// ignore_for_file: non_constant_identifier_names

import 'dart:core';

import 'package:mobx/mobx.dart';
import 'dart:convert';

enum TwoFaStrategy {
  lone,
  login,
  transfer,
  seed,
  all,
}

@observable
class Settings {
  @observable
  bool biometricEnabled = false; //Has the user enabled biometric authentication

  @observable
  bool? totalBalanceVisible = true; //Show the total balance
  @observable
  String? TOTPKey; //Is there an OTP key set for the user?
  String? padding; //Padding for the OTP key

  Settings(
      {this.biometricEnabled = false,
      this.TOTPKey,
      this.padding,
      this.totalBalanceVisible = true});

  factory Settings.clone(Settings original) {
    return Settings(
      biometricEnabled: original.biometricEnabled,
      TOTPKey: original.TOTPKey,
      padding: original.padding,
      totalBalanceVisible: original.totalBalanceVisible,
    );
  }

  String toJSON() {
    Map<String, dynamic> json = {
      'biometricEnabled': biometricEnabled,
      'padding': padding,
      'TOTPKey': TOTPKey,
      'totalBalanceVisible': totalBalanceVisible == true ? 'true' : 'false'
    };
    return jsonEncode(json);
  }

  factory Settings.fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Settings(
      biometricEnabled: json['biometricEnabled'],
      padding: json['padding'] ?? null,
      TOTPKey: json['TOTPKey'],
      totalBalanceVisible: json['totalBalanceVisible'] == null
          ? false
          : json['totalBalanceVisible'] == "true"
              ? true
              : false,
    );
  }
}
