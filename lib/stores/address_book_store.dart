import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';

part 'address_book_store.g.dart';

// ignore: library_private_types_in_public_api
class AddressBookStore = _AddressBookStore with _$AddressBookStore;

abstract class _AddressBookStore with Store {
  @observable
  ObservableList<QubicListVm> addressBook = ObservableList<QubicListVm>();

  @action
  void addAddressBook(QubicListVm qubicId) {
    addressBook.add(qubicId);
  }

  @action
  void removeAddressBook(QubicListVm qubicId) {
    addressBook.remove(qubicId);
  }
}
