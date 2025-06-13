import 'package:bloc_app/bloc/block_actions.dart';
import 'package:bloc_app/bloc/person.dart';
import 'package:bloc_app/bloc/persons_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

const mockedPersons1 = [
  Person(age: 20, name: 'Foo'),
  Person(age: 30, name: 'Bar'),
];

const mockedPersons2 = [
  Person(age: 20, name: 'Foo'),
  Person(age: 30, name: 'Bar'),
];

Future<Iterable<Person>> mockGetPersons1(_) => Future.value(mockedPersons1);

Future<Iterable<Person>> mockGetPersons2(_) => Future.value(mockedPersons1);

void main() {
  group('Testing bloc', () {
    //
    late PersonsBloc bloc;

    setUp(() {
      bloc = PersonsBloc();
    });

    blocTest<PersonsBloc, FetchResult?>(
      'Test initial state',
      build: () => bloc,
      verify: (bloc) {
        return expect(bloc.state, null);
      },
    );

    blocTest<PersonsBloc, FetchResult?>(
      'Mock retrieving persons from first iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(LoadPersonsAction(url: 'test_url', loader: mockGetPersons1));
        bloc.add(LoadPersonsAction(url: 'test_url', loader: mockGetPersons1));
      },
      expect: () => [
        FetchResult(persons: mockedPersons1, isRetrivedFromCache: false),
        FetchResult(persons: mockedPersons1, isRetrivedFromCache: true),
      ],
    );

    blocTest<PersonsBloc, FetchResult?>(
      'Mock retrieving persons from second iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(LoadPersonsAction(url: 'test_url2', loader: mockGetPersons2));
        bloc.add(LoadPersonsAction(url: 'test_url2', loader: mockGetPersons2));
      },
      expect: () => [
        FetchResult(persons: mockedPersons2, isRetrivedFromCache: false),
        FetchResult(persons: mockedPersons2, isRetrivedFromCache: true),
      ],
    );
  });
}
