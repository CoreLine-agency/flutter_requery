import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool _isPrimitive(dynamic subKey) {
  return subKey is String || subKey is int || subKey is bool;
}

String _transformKey(dynamic args) {
  if (args is String) {
    return args;
  }
  if (args is List) {
    if (args.isEmpty) {
      throw 'Cache key can\'t be empty. Add at least one value inside your composite key.';
    }
    if (!_isPrimitive(args[0])) {
      throw 'Cache key ${args[0]} must be a serializable primitive. Please use int, bool or String values';
    }

    return args.skip(1).fold(args.first.toString(), (acc, e) {
      try {
        if (!_isPrimitive(e)) {
          throw 'Cache key $e must be a serializable primitive. Please use int, bool or String values';
        }
        return "${acc}_$e";
      } catch (e) {
        throw "Cache subkey isn\'t serializable";
      }
    });
  }
  return '';
}

class QueryResponse<T> {
  T data;
  bool loading;
  dynamic error;

  QueryResponse({
    @required this.data,
    @required this.loading,
    @required this.error,
  });
}

class _QueryNotifier extends ChangeNotifier {
  Map<String, QueryResponse> cache = Map();
  Map<String, bool> refetchedQueries = Map();

  executeAndStoreQuery(Function func, String cacheKey) async {
    try {
      refetchedQueries[cacheKey] = false;
      dynamic data = await func();
      cache[cacheKey] = QueryResponse(data: data, loading: false, error: null);
    } catch (e) {
      cache[cacheKey] = QueryResponse(data: null, loading: false, error: e);
    } finally {
      notifyListeners();
    }
  }

  refetch(String cacheKey) async {
    if (cache.containsKey(cacheKey)) {
      QueryResponse response = cache[cacheKey];
      refetchedQueries[cacheKey] = true;
      cache[cacheKey] =
          QueryResponse(data: response.data, error: null, loading: true);
      notifyListeners();
    }
  }
}

QueryResponse<T> useQuery<T extends dynamic>(
  BuildContext context,
  dynamic key,
  Function func,
) {
  String cacheKey = _transformKey(key);
  _QueryNotifier provider = Provider.of<_QueryNotifier>(context, listen: true);

  if (!provider.cache.containsKey(cacheKey)) {
    provider.executeAndStoreQuery(func, cacheKey);
    return QueryResponse<T>(data: null, loading: true, error: null);
  } else {
    QueryResponse cachedResponse = provider.cache[cacheKey];
    bool shouldRefetch = provider.refetchedQueries.containsKey(cacheKey) &&
        provider.refetchedQueries[cacheKey];
    if (shouldRefetch) {
      provider.executeAndStoreQuery(func, cacheKey);
      return QueryResponse<T>(
          data: cachedResponse.data, loading: true, error: null);
    }
    if (cachedResponse.error != null) {
      return QueryResponse<T>(
          data: null, loading: false, error: cachedResponse.error);
    }
    return QueryResponse<T>(
        data: cachedResponse.data, loading: false, error: null);
  }
}

void resetStore(BuildContext context) {
  _QueryNotifier provider = Provider.of<_QueryNotifier>(context, listen: false);
  provider.cache.clear();
}

void refetchQueries(BuildContext context, List<dynamic> keys) {
  List<String> cacheKeys = keys.map((k) => _transformKey(k)).toList();
  _QueryNotifier provider = Provider.of<_QueryNotifier>(context, listen: false);
  cacheKeys.forEach((k) {
    provider.refetch(k);
  });
}

typedef _QueryBuilder = Widget Function(
  BuildContext context,
  dynamic data,
  bool loading,
  dynamic error,
);
typedef _QueryFuture<T> = Future<T> Function();

class Query<T> extends StatefulWidget {
  final dynamic cacheKey;
  final String transformedKey;
  final _QueryFuture<T> future;
  final _QueryBuilder builder;

  Query({
    @required this.cacheKey,
    @required this.builder,
    @required this.future,
  }) : transformedKey = _transformKey(cacheKey);

  @override
  _QueryState<T> createState() => _QueryState<T>();
}

class _QueryState<T> extends State<Query<T>> {
  @override
  Widget build(Object context) {
    return Selector<_QueryNotifier, QueryResponse>(
        selector: (context, _QueryNotifier query) {
      return query.cache.containsKey(widget.transformedKey)
          ? query.cache[widget.transformedKey]
          : null;
    }, builder: (context, _, __) {
      QueryResponse response =
          useQuery<T>(context, widget.cacheKey, widget.future);

      return this
          .widget
          .builder(context, response.data, response.loading, response.error);
    });
  }
}

class QueryProvider extends StatelessWidget {
  final Widget child;
  QueryProvider({this.child});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_QueryNotifier>(
      create: (context) => _QueryNotifier(),
      builder: (context, _) {
        return this.child;
      },
    );
  }
}
