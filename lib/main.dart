import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

extension Log on Object {
  void log() => dev.log(toString());
}

void main() {
  runApp(
    MaterialApp(
      title: 'Bloc',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(create: (_) => PersonsBloc(), child: const HomePage()),
    ),
  );
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction extends LoadAction {
  final PersonalUrl url;

  const LoadPersonsAction({required this.url});
}

enum PersonalUrl { person1, person2 }

extension UrlString on PersonalUrl {
  String get urlString {
    switch (this) {
      case PersonalUrl.person1:
        return 'http://127.0.0.1:5500/api/persons1.json';
      case PersonalUrl.person2:
        return 'http://127.0.0.1:5500/api/persons2.json';
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  Person.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      age = json['age'] as int;

  @override
  String toString() {
    return "Person ($name)";
  }
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResult {
  final Iterable<Person>? persons;
  final bool isRetrivedFromCache;

  const FetchResult({required this.persons, required this.isRetrivedFromCache});

  @override
  String toString() =>
      'FetchResult (isRetrivedFromCache: $isRetrivedFromCache, persons: $persons)';
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonalUrl, Iterable<Person>> _cache = {};

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
        final persons = await getPersons(url.urlString);

        _cache[url] = persons;
        final result = FetchResult(persons: persons, isRetrivedFromCache: true);

        emit(result);
      }
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloc'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(
                    LoadPersonsAction(url: PersonalUrl.person1),
                  );
                },
                child: const Text('Load JSON #1'),
              ),
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(
                    LoadPersonsAction(url: PersonalUrl.person2),
                  );
                },
                child: const Text('Load JSON #2'),
              ),
            ],
          ),
          BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previous, current) {
              return previous?.persons != current?.persons;
            },
            builder: (context, state) {
              state?.log();

              final persons = state?.persons;

              if (persons == null) {
                return const SizedBox();
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index]!;

                    return ListTile(title: Text(person.name));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
