import 'package:flutter/material.dart';

typedef QueryFuture<T> = Future<T> Function();

typedef QueryBuilder<T> = Widget Function(
  BuildContext context,
  QueryResponse<T> response,
);

class QueryResponse<T> {
  T? data;
  bool loading;
  dynamic error;

  QueryResponse({
    this.data,
    this.loading = false,
    this.error,
  });
}
