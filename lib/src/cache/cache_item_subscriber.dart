import 'package:flutter/material.dart';

class CacheItemSubscriber {
  final int id;
  final VoidCallback refetch;
  final VoidCallback fromCache;

  CacheItemSubscriber({
    required this.id,
    required this.refetch,
    required this.fromCache,
  });
}
