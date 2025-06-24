import 'package:mobx/mobx.dart';
import 'package:safe_device/safe_device.dart';

part 'root_jailbreak_flag_store.g.dart';

class RootJailbreakFlagStore = _RootJailbreakFlagStore
    with _$RootJailbreakFlagStore;

abstract class _RootJailbreakFlagStore with Store {
  @observable
  bool isRootedOrJailbroken = false;

  _RootJailbreakFlagStore() {
    setRootedOrJailbroken();
  }

  @action
  Future<void> setRootedOrJailbroken() async {
    bool isSafeDevice = await SafeDevice.isSafeDevice;
    isRootedOrJailbroken = isSafeDevice;
  }
}
