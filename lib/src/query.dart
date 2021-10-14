import 'package:flutter/widgets.dart';
import 'package:flutter_requery/src/cache/cache_item_subscriber.dart';
import 'package:flutter_requery/src/cache/internal_cache.dart';
import 'package:flutter_requery/src/types.dart';

class Query<T> extends StatefulWidget {
  final dynamic cacheKey;
  final QueryFuture<T> future;
  final QueryBuilder<T> builder;

  Query(
    this.cacheKey, {
    required this.builder,
    required this.future,
  });

  @override
  _QueryState<T> createState() => _QueryState<T>();
}

class _QueryState<T> extends State<Query<T>> {
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
      builder: (BuildContext context, AsyncSnapshot<QueryResponse<T>?> snapshot) {
        if (snapshot.data == null) {
          return Container();
        }
        return widget.builder(context, snapshot.data!);
      },
    );
  }
}
