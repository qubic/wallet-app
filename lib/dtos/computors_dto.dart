class ComputorsDto {
  final int epoch;
  final List<String> identities;
  final String signatureHex;

  ComputorsDto({
    required this.epoch,
    required this.identities,
    required this.signatureHex,
  });

  factory ComputorsDto.fromJson(Map<String, dynamic> json) => ComputorsDto(
        epoch: json["epoch"],
        identities: List<String>.from(json["identities"].map((x) => x)),
        signatureHex: json["signatureHex"],
      );

  Map<String, dynamic> toJson() => {
        "epoch": epoch,
        "identities": List<dynamic>.from(identities.map((x) => x)),
        "signatureHex": signatureHex,
      };
}
