class TransactionsDto {
  final Pagination pagination;
  final List<TransactionGroup> transactions;

  TransactionsDto({
    required this.pagination,
    required this.transactions,
  });

  factory TransactionsDto.fromJson(Map<String, dynamic> json) {
    return TransactionsDto(
      pagination: Pagination.fromJson(json['pagination']),
      transactions: (json['transactions'] as List)
          .map((e) => TransactionGroup.fromJson(e))
          .toList(),
    );
  }
}

class Pagination {
  final int totalRecords;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int nextPage;
  final int previousPage;

  Pagination({
    required this.totalRecords,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.nextPage,
    required this.previousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalRecords: json['totalRecords'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      pageSize: json['pageSize'],
      nextPage: json['nextPage'],
      previousPage: json['previousPage'],
    );
  }
}

class TransactionGroup {
  final int tickNumber;
  final String identity;
  final List<TransactionDto> transactions;

  TransactionGroup({
    required this.tickNumber,
    required this.identity,
    required this.transactions,
  });

  factory TransactionGroup.fromJson(Map<String, dynamic> json) {
    return TransactionGroup(
      tickNumber: json['tickNumber'],
      identity: json['identity'],
      transactions: (json['transactions'] as List)
          .map((e) => TransactionDto.fromJson(e))
          .toList(),
    );
  }
}

class TransactionDto {
  final Transaction transaction;
  final String timestamp;
  final bool moneyFlew;

  TransactionDto({
    required this.transaction,
    required this.timestamp,
    required this.moneyFlew,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      transaction: Transaction.fromJson(json['transaction']),
      timestamp: json['timestamp'],
      moneyFlew: json['moneyFlew'],
    );
  }
}

class Transaction {
  final String sourceId;
  final String destId;
  final String amount;
  final int tickNumber;
  final int inputType;
  final int inputSize;
  final String inputHex;
  final String signatureHex;
  final String txId;

  Transaction({
    required this.sourceId,
    required this.destId,
    required this.amount,
    required this.tickNumber,
    required this.inputType,
    required this.inputSize,
    required this.inputHex,
    required this.signatureHex,
    required this.txId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      sourceId: json['sourceId'],
      destId: json['destId'],
      amount: json['amount'],
      tickNumber: json['tickNumber'],
      inputType: json['inputType'],
      inputSize: json['inputSize'],
      inputHex: json['inputHex'],
      signatureHex: json['signatureHex'],
      txId: json['txId'],
    );
  }
}
