import 'package:flutter_requery/src/cache/cache_item_subscriber.dart';

class CacheItem<T> {
  List<CacheItemSubscriber> subscribers;
  dynamic key;
  T? data;

  CacheItem({
    required this.subscribers,
    required this.key,
  });
}
