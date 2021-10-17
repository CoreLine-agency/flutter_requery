Flutter library for fetching, caching and invalidating asynchronous data

## Quick Features

- Fetch asynchronous data
- Data invalidation
- Optimistic response
- Reset cache

## Motivation

How to do API calls in Flutter? Probably, majority would answer by using [Dio](https://pub.dev/packages/dio).\
But the real question would be, how to integrate API calls in Flutter arhitecture seamless?
One way would be to use [FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
or maybe [Bloc](https://bloclibrary.dev/#/) like most of the community do.

The thing is, both FutureBuilder and Bloc have flaws.\
For example, FutureBuilder is too simple. It does provide status of your query, but communicating with some FutureBuilder is impossible outside of the scope of the current screen.\
Problem with Bloc is that will include so many boilerplate code for a simple API call but again, talking to the Bloc is impossible from other screens. Bloc should be
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

Idea behind having keys specified as list is that you can invalidate your queries more intelligently.\
Take a look at [invalidation](#invalidation) chapter for more details.

### Query

Once the cache key is defined, next step is to write the query.\
Query takes 3 arguments:

- **cacheKey** - look [here](#cache-key) for more info.
- **future** - async action which will be executed.
- **builder** - follows the Flutter builder pattern. First parameter is `BuildContext` followed by `QueryResponse` object.

QueryResponse manages query status. It also has 3 properties:

- **data** - response received from the future or null if the exception occured.
- **loading** - boolean, true if the query is running. Otherwise, it's false.
- **error** - represents an error received from the future. If the future was successful, `error` will be null.

```dart
// use Query widget in the build method
Query<List<String>>(
  'myCacheKey',
  future: ()async {
    await Future.delayed(Duration(seconds: 1));
    return ["Hello"]
  }
  builder: (context, QueryResponse response) {
    /// error state
    if (response.error != null) {
      return Text('Error');
    }
    /// loading state
    if (response.loading) {
      return Text('Loading...');
    }
    final children = response.data.map((str) => Text(str)).toList();
    return ListView(
      children: children
    );
  },
);
```

### Invalidation

Data invalidation can come in two different forms.\
You can either afford to wait for the API response or you simply need to show the newest data as soon as possible.
If you are interested in following, check the [next](#optimistic-response) chapter.

Waiting for the API response is more common and **flutter_requery** supports this by using the `queryCache` instance.
It's global and already defined by the library. Invalidate your query by passing the cache keys.

```dart
// invalidates strKey query
queryCache.invalidateQueries('strKey');

// support for bulk invalidation
queryCache.invalidateQueries(['strKey1', 'strKey2']);

// if your keys are lists, end result would be similar to
queryCache.invalidateQueries([
  ['strKey', 1],
  ['strKey2', 2]
]);
```

Once query is invalidated, every `Query` widget subscribed for that query
will execute `future` again and rebuild its children with the new data.

For cache-level invalidation use:

```dart
// invalidate every query stored in cache
queryCache.invalidateAll()
```

Invalidation works in pair with the keys defined as lists.
Cache keys defined as list must be looked upon in a hierarchical manner where the list elements defined before are ancestors of the elements that come after.
For example:

```dart
// requests is ancestor of 1
const key1 = ["requests", 1]
```

Reasoning behind this is to support hierarchical invalidation.
Sometimes it can get cumbersome managing invalidations and therefore developer can decide to cleverly name keys to support this.
For example:

```dart
const k1 = ["requests", 1]
const k2 = ["requests", 2]
const k3 = "requests"

// without hierarchical invalidation you need to call
queryCache.invalidateQueries([
  ["requests", 1], ["requests", 2], "requests"
]);

// but with hierarchical invalidation you only need to call
queryCache.invalidateQueries("requests");
```

### Optimistic response

Sometimes waiting period for the API response to be available is too long.
Therefore you can immediately update the cache data and rebuild your widget tree by using the optimistic response.
Make sure to remove `await` keyword before the API call since this will block the thread.

```dart
  queryCache.setOptimistic("requests", [...oldData, newData]);
```

### Reset

In short, reset can be explained as cache-level invalidation without rebuilding the widget tree.\
Also, async actions won't be ran immediately but only when the new `Query` widget is mounted or the `cacheKey` has changed.
This is particularly useful for the log out action.

```dart
queryCache.reset();
```

## Summary

| API                                              | Description                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------- |
| [Query](#query)                                  | Flutter widget used for data-fetching operations.                           |
| [queryCache.invalidateQueries](#cache-key)       | Invalidates query specified by cache key and rebuilds the widget tree.      |
| [queryCache.invalidateAll](#invalidation)        | Invalidates every query stored in cache and rebuilds the widget tree.       |
| [queryCache.setOptimistic](#optimistic-response) | Set cache data manually and rebuild the widget tree.                        |
| [queryCache.reset](#reset)                       | Invalidates every query stored in cache without rebuilding the widget tree. |
