// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_book_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AddressBookStore on _AddressBookStore, Store {
  late final _$addressBookAtom =
      Atom(name: '_AddressBookStore.addressBook', context: context);

  @override
  ObservableList<QubicListVm> get addressBook {
    _$addressBookAtom.reportRead();
    return super.addressBook;
  }

  @override
  set addressBook(ObservableList<QubicListVm> value) {
    _$addressBookAtom.reportWrite(value, super.addressBook, () {
      super.addressBook = value;
    });
  }

  late final _$_AddressBookStoreActionController =
      ActionController(name: '_AddressBookStore', context: context);

  @override
  void addAddressBook(QubicListVm qubicId) {
    final _$actionInfo = _$_AddressBookStoreActionController.startAction(
        name: '_AddressBookStore.addAddressBook');
    try {
      return super.addAddressBook(qubicId);
    } finally {
      _$_AddressBookStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeAddressBook(QubicListVm qubicId) {
    final _$actionInfo = _$_AddressBookStoreActionController.startAction(
        name: '_AddressBookStore.removeAddressBook');
    try {
      return super.removeAddressBook(qubicId);
    } finally {
      _$_AddressBookStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
addressBook: ${addressBook}
    ''';
  }
}
