class PaginationRequestModel {
  final int page;
  final int pageSize;
  bool isDescending;

  PaginationRequestModel(
      {required this.page, required this.pageSize, this.isDescending = false});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['pageSize'] = pageSize;
    data['desc'] = isDescending;
    return data;
  }
}
