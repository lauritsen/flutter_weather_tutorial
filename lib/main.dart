import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:flutter_weather/simple_bloc_observer.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_weather/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:screen/screen.dart';

import 'blocs/blocs.dart';

void main() {
  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(httpClient: http.Client()));

  Bloc.observer = SimpleBlocObserver();

  runApp(
    BlocProvider(
      create: (context) => ThemeBloc(),
      child: App(weatherRepository: weatherRepository),
    ),
  );
}

class App extends StatelessWidget {
  final WeatherRepository weatherRepository;

  App({Key key, @required this.weatherRepository})
      : assert(weatherRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Flutter Weather',
          home: BlocProvider(
              create: (context) =>
                  WeatherBloc(weatherRepository: weatherRepository),
              child: Weather()),
        );
      },
    );
  }
}
