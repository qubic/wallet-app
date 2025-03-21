import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/helpers/explorer_helpers.dart';

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

//TODO Adjust as needed
final featuredApp = DAppModel(
  name: "Qubic",
  icon: "assets/images/qx.jpg",
  url: "https://qx.qubic.org/",
  description:
      "QX is a decentralized exchange running as a smart contract on the Qubic network",
);

final explorerApp = DAppModel(
    name: "Qubic Explorer",
    icon:
        "https://media.licdn.com/dms/image/v2/D560BAQFpyufUFSY-zg/company-logo_200_200/company-logo_200_200/0/1730965355499/qubicnetwork_logo?e=1749081600&v=beta&t=F9UXA_X3wNiQypJnc-kwjPvVw0EqeUr0q7oDibeukkk",
    url: getExplorerBaseUrl(),
    description: "Access easily to all the blockchain data.");

//TODO Adjust as needed
final List<DAppModel> dAppsList = [
  DAppModel(
    name: "Qx",
    icon:
        "https://media.licdn.com/dms/image/v2/D560BAQFpyufUFSY-zg/company-logo_200_200/company-logo_200_200/0/1730965355499/qubicnetwork_logo?e=1749081600&v=beta&t=F9UXA_X3wNiQypJnc-kwjPvVw0EqeUr0q7oDibeukkk",
    url: "https://qx.qubic.org",
    description: "1st Qubic decentralised exchange.",
  ),
  DAppModel(
    name: "QEarn",
    icon: "https://framerusercontent.com/images/OlRHyS54DdB86UYF7BlAZbFQ.png",
    url: "https://www.qearn.org/",
    description: "Earn Rewards by Staking \$QUBIC.",
  ),
  DAppModel(
    name: "Uniswap",
    icon:
        "https://cdn.brandfetch.io/idoYtBNi2C/w/800/h/800/theme/light/symbol.png?c=1dxbfHSJFAPEGdCLU4o5B",
    url: "https://uniswap.org",
    description: "Ethereum blockchain-based.",
  ),
  DAppModel(
    name: "OpenSea",
    icon:
        "https://pageflows.imgix.net/media/logos/opensea.png?auto=compress&ixlib=python-1.1.2&s=459d52d3fe14f0c5ab2ade3916d4c862",
    url: "https://opensea.io",
    description: "NFT marketplace.",
  )
];
