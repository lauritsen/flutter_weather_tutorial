import 'package:flutter/material.dart';
import 'package:flutter_weather/blocs/blocs.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/widgets/widgets.dart';

import 'dart:async';

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Weather'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                final city = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CitySelection(),
                    ));
                if (city != null) {
                  BlocProvider.of<WeatherBloc>(context)
                      .add(WeatherRequested(city: city));
                }
              },
            )
          ],
        ),
        body: Center(
          child: BlocConsumer<WeatherBloc, WeatherState>(
            listener: (context, state) {
              if (state is WeatherLoadSuccess) {
                _refreshCompleter?.complete();
                _refreshCompleter = Completer();
              }
            },
            builder: (context, state) {
              if (state is WeatherInitial) {
                return Center(child: Text('Please select a location'));
              }
              if (state is WeatherLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is WeatherLoadSuccess) {
                final weather = state.weather;

                return RefreshIndicator(
                  onRefresh: () {
                    BlocProvider.of<WeatherBloc>(context).add(
                      WeatherRefreshRequested(city: state.weather.location),
                    );
                    return _refreshCompleter.future;
                  },
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 100.0),
                        child: Center(
                          child: Location(location: weather.location),
                        ),
                      ),
                      Center(
                        child: LastUpdated(dateTime: weather.lastUpdated),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                        child: CombinedWeatherTemperature(
                          weather: weather,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is WeatherLoadFailure) {
                return Text(
                  'Something went wrong!',
                  style: TextStyle(color: Colors.red),
                );
              }
              return Container();
            },
          ),
        ));
  }
}
