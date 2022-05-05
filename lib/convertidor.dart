import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Convertidor extends StatefulWidget {
  Convertidor({Key? key}) : super(key: key);

  @override
  State<Convertidor> createState() => _ConvertidorState();
}

Future<Exchange> fetchAlbum() async {
  final response = await http.get(
      Uri.parse('https://api.apilayer.com/fixer/latest?base=USD&symbols=MXN'),
      headers: {"apikey": "FFVnp4v6sdsqOmHnA5dS72wjCzPMrVhm"});

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Exchange.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load exchange');
  }
}

class Exchange {
  final bool success;
  final int timestamp;
  final String base;
  final String date;
  final dynamic rates;
  final double exchange;

  const Exchange({
    required this.success,
    required this.timestamp,
    required this.base,
    required this.date,
    required this.rates,
    required this.exchange,
  });

  factory Exchange.fromJson(Map<String, dynamic> json) {
    return Exchange(
      success: json['success'],
      timestamp: json['timestamp'],
      base: json['base'],
      date: json['date'],
      rates: json['rates'],
      exchange: json['rates']['MXN'],
    );
  }
}

class _ConvertidorState extends State<Convertidor> {
  late Future<Exchange> futureAlbum;

  double cantidaddolares = 0;
  double dolaresapesos = 0;
  double cantidaddepesos = 0;
  double pesosadolares = 0;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "Cambio de moneda USD - MXN",
          style: TextStyle(
              color: Colors.black87,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              FutureBuilder<Exchange>(
                future: futureAlbum,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      child: Column(children: [
           
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            initialValue: snapshot.data!.date,
                            decoration: InputDecoration(
                              labelText: 'Fecha actual',
                            ),
                            enabled: false,
                            onChanged: (value) => value,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            initialValue:
                                snapshot.data!.exchange.toStringAsFixed(4),
                            decoration: InputDecoration(
                              labelText: 'Valor del dólar en MXN',
                            ),
                            enabled: false,
                            onChanged: (value) => value,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: 'Cantidad de dólares',
                                hintText: 'Ingrese la cantidad de dólares'),
                            onChanged: (value) {
                              setState(() {
                                cantidaddolares = double.parse(value);
                                dolaresapesos =
                                    cantidaddolares * snapshot.data!.exchange;
                                //print(dolaresapesos.toString());
                              });
                            },

                        
                          ),
                        ),
                        Text(cantidaddolares.toString() +
                            ' USD = ' +
                            dolaresapesos.toStringAsFixed(3) +
                            ' MXN'),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: 'Cantidad de pesos',
                                hintText: 'Ingrese la cantidad de pesos'),
                            onChanged: (value) {
                              setState(() {
                                cantidaddepesos = double.parse(value);
                                pesosadolares =
                                    cantidaddepesos / snapshot.data!.exchange;
                             
                              });
                            },

                          
                          ),
                        ),
                        Text(cantidaddepesos.toString() +
                            ' MXN = ' +
                            pesosadolares.toStringAsFixed(3) +
                            ' USD'),
                      ]),
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
