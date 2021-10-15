/// Contains fields for representing the query state.
class QueryResponse<T> {
  /// Data returned from the asynchronous action.
  ///
  /// If the function returned null or if the function threw exception, [data] will be null.
  T? data;

  /// Loading status of the asynchronous action.
  ///
  /// If the action is currently being ran [loading] will be true. Otherwise, it will be false.
  bool loading;

  /// Error status of the asynchronous action.
  ///
  /// If the action threw exception, that exception will be stored in [error]. Otherwise, it will be null.
  dynamic error;

  /// Creates [QueryResponse] instance
  QueryResponse({
    this.data,
    this.loading = false,
    this.error,
  });
}
