import 'package:flutter_requery/src/cache/internal_cache.dart';

class QueryCache {
  invalidateQueries(dynamic keys) => internalCache.invalidateQueries(keys);
  reset() => internalCache.reset();
  clear() => internalCache.clear();
  setOptimistic<T>(dynamic key, T data) => internalCache.setOptimistic(key, data);
}

var queryCache = QueryCache();
