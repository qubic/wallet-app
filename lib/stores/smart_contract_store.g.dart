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
  Computed<Map<String, TokenModel>>? _$_tokensByIdComputed;

  @override
  Map<String, TokenModel> get _tokensById => (_$_tokensByIdComputed ??=
          Computed<Map<String, TokenModel>>(() => super._tokensById,
              name: 'SmartContractStoreBase._tokensById'))
      .value;
  Computed<Map<String, LabeledAddressModel>>? _$_labeledAddressesByIdComputed;

  @override
  Map<String, LabeledAddressModel> get _labeledAddressesById =>
      (_$_labeledAddressesByIdComputed ??=
              Computed<Map<String, LabeledAddressModel>>(
                  () => super._labeledAddressesById,
                  name: 'SmartContractStoreBase._labeledAddressesById'))
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

  late final _$tokensAtom =
      Atom(name: 'SmartContractStoreBase.tokens', context: context);

  @override
  List<TokenModel> get tokens {
    _$tokensAtom.reportRead();
    return super.tokens;
  }

  @override
  set tokens(List<TokenModel> value) {
    _$tokensAtom.reportWrite(value, super.tokens, () {
      super.tokens = value;
    });
  }

  late final _$labeledAddressesAtom =
      Atom(name: 'SmartContractStoreBase.labeledAddresses', context: context);

  @override
  List<LabeledAddressModel> get labeledAddresses {
    _$labeledAddressesAtom.reportRead();
    return super.labeledAddresses;
  }

  @override
  set labeledAddresses(List<LabeledAddressModel> value) {
    _$labeledAddressesAtom.reportWrite(value, super.labeledAddresses, () {
      super.labeledAddresses = value;
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

  late final _$loadTokensAsyncAction =
      AsyncAction('SmartContractStoreBase.loadTokens', context: context);

  @override
  Future<void> loadTokens() {
    return _$loadTokensAsyncAction.run(() => super.loadTokens());
  }

  late final _$loadLabeledAddressesAsyncAction = AsyncAction(
      'SmartContractStoreBase.loadLabeledAddresses',
      context: context);

  @override
  Future<void> loadLabeledAddresses() {
    return _$loadLabeledAddressesAsyncAction
        .run(() => super.loadLabeledAddresses());
  }

  @override
  String toString() {
    return '''
contracts: ${contracts},
tokens: ${tokens},
labeledAddresses: ${labeledAddresses}
    ''';
  }
}
