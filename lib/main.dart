import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
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

enum City {
  stockholm,
  paris,
  tokyo,
  // riyadh going to add an error
  riyadh,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) async {
  return Future.delayed(
    const Duration(seconds: 1),
    () => {
      City.stockholm: '❄️',
      City.paris: '⛈️',
      City.tokyo: '💨',
    }[city]!,
  );
}

// UI writes to this adn reads from this
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

const unknownWeatherEmoji = '🤷🏻‍♂️';

// UI reads this
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    }
    return unknownWeatherEmoji;
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
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
                    'Error 🥲',
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
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  onTap: () =>
                      ref.read(currentCityProvider.notifier).state = city,
                  title: Text(
                    city.toString(),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
