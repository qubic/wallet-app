import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';

class CustomFormFieldValidators {
  static FormFieldValidator<T> isLessThanParsed<T>(
      {required int lessThan, required BuildContext context}) {
    return (T? valueCandidate) {
      final l10n = l10nOf(context);

      if (valueCandidate == null) {
        return null;
      }

      if (lessThan == 0) {
        return l10n.generalErrorZeroQubicFunds;
      }

      String toParse = (valueCandidate as String)
          .replaceAll(" ", "")
          .replaceAll(l10n.generalLabelCurrencyQubic, "")
          .replaceAll(",", "");

      int? parsedVal = int.tryParse(toParse);
      if (parsedVal == null) {
        return l10n.generalErrorNotNumeric;
      }
      if (parsedVal > lessThan) {
        return l10n.generalErrorNotEnoughQubicFunds;
      }

      return null;
    };
  }

  static FormFieldValidator<T> isLessThanParsedAsset<T>(
      {required int lessThan, required BuildContext context}) {
    return (T? valueCandidate) {
      final l10n = l10nOf(context);

      if (valueCandidate == null) {
        return null;
      }

      if (lessThan == 0) {
        return l10n.generalErrorNotEnoughAssets;
      }

      String toParse = valueCandidate as String;
      toParse.indexOf(" ");
      toParse = toParse.substring(0, toParse.indexOf(" ")).replaceAll(",", "");

      int? parsedVal = int.tryParse(toParse);
      if (parsedVal == null) {
        return l10n.generalErrorNotNumeric;
      }
      if (parsedVal > lessThan) {
        return l10n.generalErrorNotEnoughTokens;
      }

      return null;
    };
  }

  static FormFieldValidator<T> presentTick<T>(
      {required int currentTick, required BuildContext context}) {
    final l10n = l10nOf(context);

    return (T? valueCandidate) {
      if (valueCandidate == null) {
        return null;
      }
      if ((valueCandidate as int) > currentTick) {
        return l10n.sendAssetErrorTickIsInThePast(currentTick);
      }

      return null;
    };
  }

  static FormFieldValidator<T> isLessThan<T>(
      {required int lessThan, required BuildContext context}) {
    final l10n = l10nOf(context);

    return (T? valueCandidate) {
      if (valueCandidate == null) {
        return null;
      }
      if ((valueCandidate as int) > lessThan) {
        return l10n.generalErrorValueMustBeLowerThan(lessThan);
      }

      return null;
    };
  }

  static FormFieldValidator<T> isPublicIdAvailable<T>(
      {required ObservableList<QubicListVm> currentQubicIDs,
      maxNumberOfIDs = 0,
      required BuildContext context}) {
    final l10n = l10nOf(context);

    return (T? valueCandidate) {
      if (valueCandidate == null) {
        return null;
      }
      int total = currentQubicIDs
          .where((element) =>
              element.publicId ==
              valueCandidate.toString().replaceAll(",", "_"))
          .length;
      if (total > maxNumberOfIDs) {
        return l10n.addAccountErrorPublicIDAlreadyInUse;
      }
      return null;
    };
  }

  static FormFieldValidator<T> isNameAvailable<T>(
      {required ObservableList<QubicListVm> currentQubicIDs,
      String? ignorePublicId,
      required BuildContext context}) {
    final l10n = l10nOf(context);

    return (T? valueCandidate) {
      if (valueCandidate == null) {
        return null;
      }

      int total = ignorePublicId == null
          ? currentQubicIDs
              .where((element) =>
                  element.name ==
                  valueCandidate.toString().replaceAll(",", "_"))
              .length
          : currentQubicIDs
              .where((element) =>
                  element.name ==
                      valueCandidate.toString().replaceAll(",", "_") &&
                  element.publicId != ignorePublicId)
              .length;
      if (total > 0) {
        return l10n.addAccountErrorNameAlreadyInUse;
      }
      return null;
    };
  }

  static FormFieldValidator<T> isSeed<T>(
      {String? errorText, required BuildContext context}) {
    final l10n = l10nOf(context);

    HashSet validChars = HashSet();
    validChars.addAll({
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z"
    });

    return (T? valueCandidate) {
      if (valueCandidate == null ||
          (valueCandidate is String && valueCandidate.trim().isEmpty)) {
        return errorText ?? FormBuilderLocalizations.current.requiredErrorText;
      }

      if (valueCandidate is String && valueCandidate.length != 55) {
        return l10n.generalErrorMinCharLength(55);
      }

      bool valid = true;
      for (int i = 0; i < (valueCandidate as String).length; i++) {
        if (!validChars.contains(valueCandidate[i])) {
          valid = false;
        }
      }
      if (!valid) {
        return l10n.generalErrorOnlyLowercaseChar;
      }

      return null;
    };
  }

  static FormFieldValidator<T> isPublicIDNoContext<T>({String? errorText}) {
    HashSet validChars = HashSet();
    validChars.addAll({
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    });

    return (T? valueCandidate) {
      if (valueCandidate == null ||
          (valueCandidate is String && valueCandidate.trim().isEmpty)) {
        return errorText;
      }

      if (valueCandidate is String && valueCandidate.length != 60) {
        return errorText;
      }

      bool valid = true;
      for (int i = 0; i < (valueCandidate as String).length; i++) {
        if (!validChars.contains(valueCandidate[i])) {
          valid = false;
        }
      }
      if (!valid) {
        return errorText;
      }

      return null;
    };
  }

  static FormFieldValidator<T> isPublicID<T>(
      {String? errorText, required BuildContext context}) {
    final l10n = l10nOf(context);

    HashSet validChars = HashSet();
    validChars.addAll({
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    });

    return (T? valueCandidate) {
      if (valueCandidate == null ||
          (valueCandidate is String && valueCandidate.trim().isEmpty)) {
        return errorText ?? FormBuilderLocalizations.current.requiredErrorText;
      }

      if (valueCandidate is String && valueCandidate.length != 60) {
        return l10n.generalErrorMinCharLength(60);
      }

      bool valid = true;
      for (int i = 0; i < (valueCandidate as String).length; i++) {
        if (!validChars.contains(valueCandidate[i])) {
          valid = false;
        }
      }
      if (!valid) {
        return l10n.generalErrorOnlyUppercaseChar;
      }

      return null;
    };
  }
}
