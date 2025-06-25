// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_jailbreak_flag_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RootJailbreakFlagStore on _RootJailbreakFlagStore, Store {
  late final _$isRootedOrJailbrokenAtom = Atom(
      name: '_RootJailbreakFlagStore.isRootedOrJailbroken', context: context);

  @override
  bool get isRootedOrJailbroken {
    _$isRootedOrJailbrokenAtom.reportRead();
    return super.isRootedOrJailbroken;
  }

  @override
  set isRootedOrJailbroken(bool value) {
    _$isRootedOrJailbrokenAtom.reportWrite(value, super.isRootedOrJailbroken,
        () {
      super.isRootedOrJailbroken = value;
    });
  }

  late final _$setRootedOrJailbrokenAsyncAction = AsyncAction(
      '_RootJailbreakFlagStore.setRootedOrJailbroken',
      context: context);

  @override
  Future<void> checkDeviceState() {
    return _$setRootedOrJailbrokenAsyncAction
        .run(() => super.checkDeviceState());
  }

  @override
  String toString() {
    return '''
isRootedOrJailbroken: ${isRootedOrJailbroken}
    ''';
  }
}
