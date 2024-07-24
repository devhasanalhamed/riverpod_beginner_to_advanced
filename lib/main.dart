import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

extension CapitalizeFirst on String {
  String capitalizeFirst() {
    final arr = split('');
    arr[0] = arr[0].toUpperCase();
    return arr.join('');
  }
}

enum City {
  riyadh,
  paris,
  tokyo,
  london,
  newYork,
  // shanghai going to add an error
  shanghai,
  sydney,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City? city) {
  return Future.delayed(const Duration(seconds: 1), () {
    return {
      City.riyadh: '☀️',
      City.paris: '☁️',
      City.tokyo: '🌦️',
      City.london: '🌧️',
      City.newYork: '🌩️',
      City.sydney: '🌨️',
    }[city]!;
  });
}

/*
this provider value can't be changed
final myProvider = Provider((_) => "Hello World!");
*/

// this provider value can be changed, and the UI will read, write to it
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

const unknownWeatherEmoji = "🐦";

// UI will read from this
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    } else {
      return unknownWeatherEmoji;
    }
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Future Provider'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: Center(
              child: currentWeather.when(
                data: (data) {
                  return Text(
                    data,
                    style: const TextStyle(
                      fontSize: 40.0,
                    ),
                  );
                },
                loading: () {
                  return const CircularProgressIndicator();
                },
                error: (error, stackTrace) {
                  return const Text(
                    'City Outdated 🥲',
                    style: TextStyle(
                      fontSize: 28.0,
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: City.values.length,
            itemBuilder: (context, index) {
              final city = City.values[index];
              final isSelected =
                  ref.watch(currentCityProvider.notifier).state == city;
              return ListTile(
                title: Text(city.name.capitalizeFirst()),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () =>
                    ref.read(currentCityProvider.notifier).state = city,
              );
            },
          )),
        ],
      ),
    );
  }
}
