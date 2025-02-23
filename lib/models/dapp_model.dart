class DAppModel {
  String name;
  String icon;
  String url;
  String description;

  DAppModel({
    required this.name,
    required this.icon,
    required this.url,
    required this.description,
  });
}

final List<DAppModel> dAppsList = [
  DAppModel(
    name: "Uniswap",
    icon:
        "https://cdn.brandfetch.io/idoYtBNi2C/w/800/h/800/theme/light/symbol.png?c=1dxbfHSJFAPEGdCLU4o5B",
    url: "https://uniswap.org",
    description: "Ethereum blockchain-based",
  ),
  DAppModel(
    name: "Qubic",
    icon: "https://www.google.com/s2/favicons?domain=qubic.com",
    url: "https://qubic.com",
    description:
        "Qubic is a decentralized social media platform that allows users to create their own decentralized identity and share content with the world.",
  ),
];
