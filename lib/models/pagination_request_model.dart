class PaginationRequestModel {
  final int page;
  final int pageSize;

  PaginationRequestModel({required this.page, required this.pageSize});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['pageSize'] = pageSize;
    return data;
  }
}
