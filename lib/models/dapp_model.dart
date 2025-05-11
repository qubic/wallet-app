import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/stores/network_store.dart';

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

  DAppModel copyWith({
    String? name,
    String? icon,
    String? url,
    String? description,
  }) {
    return DAppModel(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      description: description ?? this.description,
    );
  }
}

final featuredApp = DAppModel(
  name: "Qubic",
  icon: "assets/images/qx.jpg",
  url: "https://qx.qubic.org/",
  description:
      "QX is a decentralized exchange running as a smart contract on the Qubic network",
);

final Observable<DAppModel> explorerApp = Observable(DAppModel(
    name: "Qubic Explorer",
    icon:
        "https://media.licdn.com/dms/image/v2/D560BAQFpyufUFSY-zg/company-logo_200_200/company-logo_200_200/0/1730965355499/qubicnetwork_logo?e=1749081600&v=beta&t=F9UXA_X3wNiQypJnc-kwjPvVw0EqeUr0q7oDibeukkk",
    url: getIt<NetworkStore>().explorerUrl,
    description: "Access easily to all the blockchain data."));

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
    name: "QXBoard",
    icon: "",
    url: "https://www.qxboard.com/",
    description: "User Friendly QX UI for Qubic Assets.",
  ),
  DAppModel(
    name: "QXTrade",
    icon: "",
    url: "https://qubictrade.com/",
    description: "User Friendly QX UI for Qubic Assets.",
  ),
  DAppModel(
    name: "OpenSea",
    icon:
        "https://pageflows.imgix.net/media/logos/opensea.png?auto=compress&ixlib=python-1.1.2&s=459d52d3fe14f0c5ab2ade3916d4c862",
    url: "https://opensea.io",
    description: "NFT marketplace.",
  )
];
