// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_contract_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SmartContractStore on SmartContractStoreBase, Store {
  Computed<Map<String, QubicSCModel>>? _$_byIdComputed;

  @override
  Map<String, QubicSCModel> get _byId => (_$_byIdComputed ??=
          Computed<Map<String, QubicSCModel>>(() => super._byId,
              name: 'SmartContractStoreBase._byId'))
      .value;
  Computed<bool>? _$hasDataComputed;

  @override
  bool get hasData => (_$hasDataComputed ??= Computed<bool>(() => super.hasData,
          name: 'SmartContractStoreBase.hasData'))
      .value;

  late final _$contractsAtom =
      Atom(name: 'SmartContractStoreBase.contracts', context: context);

  @override
  List<QubicSCModel> get contracts {
    _$contractsAtom.reportRead();
    return super.contracts;
  }

  @override
  set contracts(List<QubicSCModel> value) {
    _$contractsAtom.reportWrite(value, super.contracts, () {
      super.contracts = value;
    });
  }

  late final _$loadSmartContractsAsyncAction = AsyncAction(
      'SmartContractStoreBase.loadSmartContracts',
      context: context);

  @override
  Future<void> loadSmartContracts() {
    return _$loadSmartContractsAsyncAction
        .run(() => super.loadSmartContracts());
  }

  @override
  String toString() {
    return '''
contracts: ${contracts},
hasData: ${hasData}
    ''';
  }
}
