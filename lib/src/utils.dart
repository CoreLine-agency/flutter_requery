bool _isPrimitive(dynamic key) {
  return key is String || key is int;
}

String _delimiter = "|";
bool _containsDelimiter(String key) {
  return key.contains(_delimiter);
}

String _transformSubKey(dynamic subKey) {
  if (!_isPrimitive(subKey)) {
    throw 'Cache key $subKey must be serializable. Please use int or String.';
  }
  if (subKey is String) {
    if (subKey.isEmpty) {
      throw 'Cache key can\'t be an empty string.';
    }
    if (_containsDelimiter(subKey)) {
      throw 'Cache key can\'t contain |';
    }
    return subKey;
  } else if (subKey is int) {
    return subKey.toString();
  } else {
    throw 'Cache key must be serializable. Please use int or String.';
  }
}

bool areKeysEqual(dynamic key1, dynamic key2) {
  final k1 = transformKey(key1);
  final k2 = transformKey(key2);
  return k1 == k2;
}

String transformKey(dynamic args) {
  if (!(args is List)) {
    return _transformSubKey(args);
  } else {
    if (args.isEmpty) {
      throw 'Cache key can\'t be empty. Add at least one value.';
    }
    String first = _transformSubKey(args[0]);

    return args.skip(1).fold(first, (acc, subKey) {
      String k = _transformSubKey(subKey);
      return "$acc$_delimiter$k";
    });
  }
}
