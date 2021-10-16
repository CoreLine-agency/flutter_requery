Flutter library for fetching, caching and invalidating asynchronous data

## Quick Features

- Fetch asynchronous data using Query widget
- Invalidate your data with queryCache instance
- Set optimistic response
- Reset cache

## Motivation

How to do API calls in Flutter? Yes, you can and you probably should use [Dio](https://pub.dev/packages/dio)
But the real question would be, how to integrate your API calls in Flutter arhitecture seamless?
You can always use [FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
or maybe [Bloc](https://bloclibrary.dev/#/) like most of the community do.

The thing is, both [FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) and [Bloc](https://bloclibrary.dev/#/) have flaws.
For example, FutureBuilder is too simple. It does provide status of your query, but communication between different queries is impossible without
building the custom solution on top of it.

Problem with [Bloc](https://bloclibrary.dev/#/) is that will include so many boilerplate code for a simple API call. [Bloc](https://bloclibrary.dev/#/) should be
number one choice for complicated workflows, but what if you don't have any complex business logic?

**flutter_requery** to the rescue!

## Example

Let's start with this simple example.

```dart
/// define data and cache key
final List<String> data = ["Hello"];
final String cacheKey = 'strKey';

/// simulates API call, therefore response is delayed
Future<List<String>> _getData() async {
  await Future.delayed(Duration(seconds: 1));
  return data;
}

/// later, used in the build method
Query<List<String>>(
  cacheKey,
  future: _getData,
  builder: (context, response) {
    if (response.error != null) {
      return Text('Error');
    }
    if (response.loading) {
      return Text('Loading...');
    }
    final children = response.data.map((str) => Text(str)).toList();
    return ListView(
      children: children
    );
  },
);

/// and later when you want to invalidate your data
void _onPress() async {
  await Future.delayed(Duration(seconds: 1));
  data.add("World");
  queryCache.invalidateQueries(cacheKey);
}
```

And that's the gist of it. You can find complete example on [pub.dev](https://pub.dev/packages/flutter_requery/example).

## Usage

### Cache key

Every query needs a cache key.\
Under this key your data will be stored in cache.
It can be string, int or list of strings and ints.

```dart

/// good
const k1 = 'myKey';
const k2 = 1;
const k3 = ["data", 1]

/// bad
const k1 = 1.0;
const k2 = true;
const k3 = ["data", true];
```

Idea behind having keys specified as an array is that you can invalidate your query more intelligently.

Take a look here for more inf.sd.a.d....
