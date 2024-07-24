import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// this extension if for the operator + while it infix between one of the
// nullable values, because our application will start with null as a default value
extension OptionalInfixAdditionAndSubtract<T extends num> on T? {
  T? operator +(T? other) {
    final shadow = this;
    if (shadow != null) {
      return shadow + (other ?? 0) as T;
    } else {
      return null;
    }
  }

  T? operator -(T? other) {
    final shadow = this;
    if (shadow != null) {
      return shadow - (other ?? 0) as T;
    } else {
      return null;
    }
  }
}

class Counter extends StateNotifier<int?> {
  Counter() : super(null);

  void increment() => state = state == null ? 1 : state + 1;

  void decrement() => state = state == null ? null : state - 1;

  void reset() => state = null;
}

final counterProvider = StateNotifierProvider<Counter, int?>(
  (ref) => Counter(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // wrapping our title with a consumer to avoid rebuild the whole scaffold
        title: Consumer(
          builder: (context, ref, child) {
            final count = ref.watch(counterProvider);
            final text = count == null ? 'Press the button' : count.toString();
            return Text(text);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: ref.read(counterProvider.notifier).increment,
            child: const Text(
              'Increment Button',
            ),
          ),
          TextButton(
            onPressed: ref.read(counterProvider.notifier).decrement,
            child: const Text(
              'Decrement Button',
            ),
          ),
          TextButton(
            onPressed: ref.read(counterProvider.notifier).reset,
            child: const Text(
              'Reset Counter',
            ),
          ),
        ],
      ),
    );
  }
}
