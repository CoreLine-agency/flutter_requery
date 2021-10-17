import 'package:flutter_requery/src/cache/internal_cache.dart';

/// Contains functions for managing the query cache.
///
/// There is only one constructor which is used only internally by this library.\
/// Developer is not supposed to instantiate this class by calling constructor.\
/// Recommended way would be to use [queryCache] instance provided by library
class QueryCache {
  /// Creates [QueryCache] instance. Not intented for developer use.\
  /// Developer should always use [queryCache] provided by the library.
  QueryCache();

  /// Invalidates the queries specified by [keys].
  ///
  /// Queries targeted by [keys] will be ran again immediately if at least
  /// one [Query] instance is  subscribed to these changes.
  ///
  /// Alternative approach would be to use optimistic response.
  /// Look at the [setOptimistic] for more details
  invalidateQueries(dynamic keys) => internalCache.invalidateQueries(keys);

  /// Invalidates every query stored in cache.
  ///
  /// Calling this method will immediately trigger rebuilding every [Query]
  /// widget currently mounted in your app
  ///
  /// If you only want to delete the cache without triggering the rebuild
  /// look at the [reset] method
  invalidateAll() => internalCache.invalidateAll();

  /// Deletes data from cache without rebuilding the [Query] widget
  ///
  /// If you want to delete the cache and trigger a rebuild,
  /// take a look at the [reset] method
  reset() => internalCache.reset();

  /// Replaces the data in cache with specified [data]
  ///
  /// Calling this method will trigger the rebuild but
  /// the query won't be called again
  ///
  /// Alternative approach would be to use invalidate queries.
  /// Look at the [invalidateQueries] for more details
  setOptimistic<T>(dynamic key, T data) =>
      internalCache.setOptimistic(key, data);
}

/// Instance of the QueryCache class.
var queryCache = QueryCache();
