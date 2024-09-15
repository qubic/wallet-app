enum TargetTickTypeEnum {
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

TargetTickTypeEnum defaultTargetTickType = TargetTickTypeEnum.autoCurrentPlus5;
