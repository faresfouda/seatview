import'package:http/http.dart' as http;
import'package:flutter/material.dart';

class apihandler extends StatefulWidget {
  const apihandler({super.key});

  @override
  State<apihandler> createState() => _apihandlerState();
}

class _apihandlerState extends State<apihandler> {
  Future<http.Response?> getpost() async {
    http.Response apipost = await http.get('https://jsonplaceholder.typicode.com/posts' as Uri);
    if (apipost.statusCode==200){
      print(apipost.body);
      return null;
    } else{
      throw Exception('can\'t load the data');
    }
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


