import 'package:bloc_app/bloc/block_actions.dart';
import 'package:bloc_app/bloc/person.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension IsEqualIgnoreOrdering<T> on Iterable<T> {
  bool isEqualToIgnoreingOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

@immutable
class FetchResult {
  final Iterable<Person>? persons;
  final bool isRetrivedFromCache;

  const FetchResult({required this.persons, required this.isRetrivedFromCache});

  @override
  String toString() =>
      'FetchResult (isRetrivedFromCache: $isRetrivedFromCache, persons: $persons)';

  @override
  bool operator ==(covariant FetchResult other) {
    return persons!.isEqualToIgnoreingOrdering(other.persons!) &&
        isRetrivedFromCache == other.isRetrivedFromCache;
  }

  @override
  int get hashCode => Object.hash(persons, isRetrivedFromCache);
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cache = {};

  PersonsBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      final url = event.url;

      if (_cache.containsKey(url)) {
        final cachedPersons = _cache[url];
        final result = FetchResult(
          persons: cachedPersons,
          isRetrivedFromCache: true,
        );

        emit(result);
      } else {
        final loader = event.loader;
        final persons = await loader(url);

        _cache[url] = persons;
        final result = FetchResult(
          persons: persons,
          isRetrivedFromCache: false,
        );

        emit(result);
      }
    });
  }
}
