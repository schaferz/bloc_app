import 'dart:convert';
import 'dart:io';
import 'package:bloc_app/bloc/block_actions.dart';
import 'package:bloc_app/bloc/person.dart';
import 'package:bloc_app/bloc/persons_bloc.dart';
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

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
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
                    LoadPersonsAction(url: personsUrl1, loader: getPersons),
                  );
                },
                child: const Text('Load JSON #1'),
              ),
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(
                    LoadPersonsAction(url: personsUrl2, loader: getPersons),
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
