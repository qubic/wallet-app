class PaginationResponseModel {
  final int? totalRecords;
  final int? currentPage;
  final int? totalPages;
  final int? pageSize;
  final int? nextPage;
  final int? previousPage;

  PaginationResponseModel({
    required this.totalRecords,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.nextPage,
    required this.previousPage,
  });

  factory PaginationResponseModel.fromJson(Map<String, dynamic> json) =>
      PaginationResponseModel(
        totalRecords: json["totalRecords"],
        currentPage: json["currentPage"],
        totalPages: json["totalPages"],
        pageSize: json["pageSize"],
        nextPage: json["nextPage"],
        previousPage: json["previousPage"],
      );
}
