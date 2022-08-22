import 'package:flutter_requery/src/cache/cache_item_subscriber.dart';
import 'package:flutter_requery/src/utils.dart';

import 'cache_item.dart';

class InternalCache {
  final Map<String, CacheItem> _cache = {};

  bool containsKey(dynamic key) {
    String transformed = transformKey(key);
    return _cache.containsKey(transformed);
  }

  void addSubscriber(dynamic key, CacheItemSubscriber subscriber) {
    String transformed = transformKey(key);

    if (containsKey(key)) {
      _cache[transformed]!.subscribers.add(subscriber);
    } else {
      _cache[transformed] = CacheItem(key: key, subscribers: [subscriber]);
    }
  }

  void removeSubscriber(dynamic key, int subscriberId) {
    if (containsKey(key)) {
      _cache[transformKey(key)]!.subscribers.removeWhere(
            (subscriber) => subscriber.id == subscriberId,
          );
    }
  }

  void addData(dynamic key, dynamic data) {
    if (containsKey(key)) {
      String transformed = transformKey(key);
      _cache[transformed]!.data = data;
    }
  }

  void clearData(dynamic key) {
    if (containsKey(key)) {
      String transformed = transformKey(key);
      _cache[transformed]!.data = null;
    }
  }

  void removeKey(dynamic key) {
    if (containsKey(key)) {
      String transformed = transformKey(key);
      _cache.remove(transformed);
    }
  }

  getData(dynamic key) {
    if (containsKey(key)) {
      String transformed = transformKey(key);
      return _cache[transformed]!.data;
    }
    return null;
  }

  setOptimistic(dynamic key, dynamic data) {
    addData(key, data);
    final subscribers = _cache[transformKey(key)]!.subscribers;
    for (var subscriber in subscribers) {
      subscriber.fromCache();
    }
  }

  invalidateQuery(dynamic key) {
    String transformed = transformKey(key);
    for (var cacheKey in _cache.keys) {
      if (cacheKey == transformed || cacheKey.startsWith('${transformed}_')) {
        final subscribers = _cache[cacheKey]!.subscribers;
        for (var subscriber in subscribers) {
          subscriber.refetch();
        }
      }
    }
  }

  invalidateQueries(dynamic keys) {
    if (!(keys is List)) {
      invalidateQuery(keys);
    } else {
      for (var key in keys) {
        invalidateQuery(key);
      }
    }
  }

  invalidateAll() {
    final keysToBeRemoved = [];
    List<CacheItemSubscriber> subscribersToBeCalled = [];
    for (var key in _cache.keys) {
      final subscribers = _cache[key]!.subscribers;
      if (subscribers.isEmpty) {
        keysToBeRemoved.add(key);
        continue;
      }
      subscribersToBeCalled.addAll(subscribers);
    }
    subscribersToBeCalled.forEach((s) => s.refetch());
    _cache.removeWhere((key, value) => keysToBeRemoved.contains(key));
  }

  reset() {
    _cache.clear();
  }
}

var internalCache = InternalCache();
