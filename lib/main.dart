import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Application',
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

// class marked as immutable means all of it's properties should be final
@immutable
class Person {
  final String name;
  final int age;
  final String uuid;

  Person({
    required this.name,
    required this.age,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();

  Person updated([String? name, int? age]) => Person(
        name: name ?? this.name,
        age: age ?? this.age,
        uuid: uuid,
      );

  String get displayName => "$name, ($age years old)";

  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  // usually you hash the values you compare with in the equivalent.
  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() => "Person(name: $name, age: $age, uuid: $uuid)";
}

// change notifier is one of the most powerful object to build data model that can have
// listeners, store complex data, it yield the change but do not specify what changed!
// no need to specify what data we are storing like generics like state notifier.

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];

  // to reach the count of people in the data model, fast and efficient.
  int get count => _people.length;

  // using unmodifiable list view from collections library to reach the people in public
  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person updatedPerson) {
    final index = _people.indexOf(updatedPerson);
    final oldPerson = _people[index];
    if (oldPerson.name != updatedPerson.name ||
        oldPerson.age != updatedPerson.age) {
      _people[index] = oldPerson.updated(
        updatedPerson.name,
        updatedPerson.age,
      );
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider(
  (ref) => DataModel(),
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final dataModel = ref.watch(peopleProvider);
          return Column(
            children: [
              if (dataModel.count == 0)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "List is empty 🥹",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: dataModel.count,
                  itemBuilder: (context, index) {
                    final person = dataModel.people[index];
                    return ListTile(
                      title: GestureDetector(
                        onTap: () async {
                          final updatedPerson =
                              await createOrUpdatePersonDialog(context, person);
                          if (updatedPerson != null) {
                            dataModel.update(updatedPerson);
                          }
                        },
                        child: Text(person.displayName),
                      ),
                      trailing: IconButton(
                        onPressed: () => dataModel.remove(person),
                        icon: const Icon(
                          Icons.delete,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final person = await createOrUpdatePersonDialog(context);
          if (person != null) {
            final dataModel = ref.read(peopleProvider);
            dataModel.add(person);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

final nameController = TextEditingController();
final ageController = TextEditingController();

Future<Person?> createOrUpdatePersonDialog(BuildContext context,
    [Person? existingPerson]) {
  String? name = existingPerson?.name;
  int? age = existingPerson?.age;
  bool isEdit = existingPerson != null;

  nameController.text = name ?? "";
  ageController.text = age?.toString() ?? "";

  return showDialog<Person?>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(isEdit ? "Update a person" : "Create a person"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Enter name here",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 32.0),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: "Enter name here",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onChanged: (value) => age = int.tryParse(value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (name != null && age != null) {
                    if (isEdit) {
                      // have existing person
                      final newPerson = existingPerson.updated(
                        name,
                        age,
                      );
                      Navigator.of(context).pop(
                        newPerson,
                      );
                    } else {
                      // no existing person, create new one
                      Navigator.of(context).pop(
                        Person(
                          name: name!,
                          age: age!,
                        ),
                      );
                    }
                  } else {
                    // no name, age or both
                    Navigator.pop(context);
                  }
                },
                child: Text(isEdit ? "Update" : "Create"),
              ),
            ],
          ));
}
