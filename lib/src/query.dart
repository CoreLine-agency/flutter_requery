import 'package:flutter/widgets.dart';
import 'package:flutter_requery/src/cache/cache_item_subscriber.dart';
import 'package:flutter_requery/src/cache/internal_cache.dart';
import 'package:flutter_requery/src/types.dart';

/// Executes async action and listens for further invalidations.
///
/// Takes [future] object which represents async action. Usually, this means API call.\
/// Takes [cacheKey] identifier which will be used for storing the [future] response\
/// Takes [builder] which follows the standard Flutter builder pattern. First
/// parameter is [BuildContext] followed by [QueryResponse] object
///
class Query<T extends Object> extends StatefulWidget {
  /// Identifier used for storing the data in cache.
  ///
  /// [cacheKey] can be int or String.
  /// ```dart
  /// const key = "rndStr";
  /// // or
  /// const key = 1;
  /// ```
  ///
  /// Also, [cacheKey] can be a list composed of Strings and ints.
  /// ```dart
  /// const key = ["rndStr", 1];
  /// ```
  final dynamic cacheKey;

  /// Async function which result will be stored in cache
  final Future<T> Function() future;

  /// Updates the widget subtree by providing a latest [QueryResponse] object to the children.
  ///
  /// Each [Query] instance will rebuild its children twice.
  /// First rebuild will be called with this [QueryResponse] instance:
  /// ```dart
  /// QueryResponse(
  ///   data: null,
  ///   loading: true,
  ///   error: null,
  /// );
  /// ```
  /// Second rebuild will be called with:
  ///```dart
  /// QueryResponse(
  ///   data: data, // null if your future throws exception
  ///   loading: false,
  ///   error: null,  // null if your [future] exited successfully
  /// );
  /// ```
  final Widget Function(
    BuildContext context,
    QueryResponse<T> response,
  ) builder;

  /// Creates [Query] instance.
  Query(
    this.cacheKey, {
    required this.builder,
    required this.future,
  });

  @override
  _QueryState<T> createState() => _QueryState<T>();
}

class _QueryState<T extends Object> extends State<Query<T>> {
  late Stream<QueryResponse<T>> stream;
  Stream<QueryResponse<T>> _createStreamFromAction<T>(
    Function cb,
  ) async* {
    try {
      T? data = internalCache.getData(widget.cacheKey);
      yield QueryResponse(data: data, loading: true);
      T response = await cb();
      internalCache.addData(widget.cacheKey, response);
      yield QueryResponse(data: response);
    } catch (e) {
      print(e);
      yield QueryResponse(error: e);
    }
  }

  Stream<QueryResponse<T>> _createStreamFromCache() async* {
    T data = internalCache.getData(widget.cacheKey)!;
    yield QueryResponse(data: data);
  }

  _initQuery() {
    if (internalCache.containsKey(widget.cacheKey)) {
      stream = _createStreamFromCache();
    } else {
      stream = _createStreamFromAction(widget.future);
    }
    internalCache.addSubscriber(
      widget.cacheKey,
      CacheItemSubscriber(
        id: widget.hashCode,
        refetch: _restartStream,
        fromCache: _rebuildStream,
      ),
    );
  }

  @override
  void initState() {
    _initQuery();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Query<T> oldWidget) {
    if (widget.cacheKey != oldWidget.cacheKey) {
      internalCache.removeSubscriber(oldWidget.cacheKey, oldWidget.hashCode);
      _initQuery();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    internalCache.removeSubscriber(widget.cacheKey, widget.hashCode);
    super.dispose();
  }

  void _restartStream() {
    if (mounted) {
      setState(() {
        stream = _createStreamFromAction(widget.future);
      });
    }
  }

  void _rebuildStream() {
    if (mounted) {
      setState(() {
        stream = _createStreamFromCache();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: null,
      stream: stream,
      builder:
          (BuildContext context, AsyncSnapshot<QueryResponse<T>?> snapshot) {
        if (snapshot.data == null) {
          return Container();
        }
        return widget.builder(context, snapshot.data!);
      },
    );
  }
}
