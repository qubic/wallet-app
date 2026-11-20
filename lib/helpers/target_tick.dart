enum TargetTickTypeEnum {
  /// Default selection: uses the remotely configured offset. Its own [value] is
  /// a placeholder — always resolve it through `WalletContentStore.offsetFor`.
  automatic(0),
  autoCurrentPlus5(5),
  autoCurrentPlus10(10),
  autoCurrentPlus20(20),
  autoCurrentPlus40(40),
  manual(-1);

  // This is the property that will hold the value
  final int value;

  // A constructor for the enum
  const TargetTickTypeEnum(this.value);
}
