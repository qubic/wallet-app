import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';

part 'address_book_store.g.dart';

// ignore: library_private_types_in_public_api
class AddressBookStore = _AddressBookStore with _$AddressBookStore;

abstract class _AddressBookStore with Store {
  @observable
  ObservableList<QubicListVm> addressBook = ObservableList<QubicListVm>();

  @action
  void loadAddressBook() {
    addressBook =
        ObservableList.of(getIt<HiveStorage>().getAddressBookEntries());
  }

  @action
  void addAddressBook(QubicListVm qubicId) {
    addressBook.add(qubicId);
    getIt<HiveStorage>().addAddressBookEntry(qubicId);
  }

  @action
  void removeAddressBook(QubicListVm qubicId) {
    addressBook.remove(qubicId);
    getIt<HiveStorage>().removeAddressBookEntry(qubicId.publicId);
  }
}
