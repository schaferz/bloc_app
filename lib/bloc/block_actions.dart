import 'package:bloc_app/bloc/person.dart';
import 'package:flutter/foundation.dart';

const personsUrl1 = 'http://127.0.0.1:5500/api/persons1.json';
const personsUrl2 = 'http://127.0.0.1:5500/api/persons2.json';

/// Person loader
typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction extends LoadAction {
  final String url;
  final PersonsLoader loader;
  const LoadPersonsAction({required this.url, required this.loader});
}
