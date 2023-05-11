import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'secrets.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> articles = [];
  bool isLoading = false;

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse(
          'https://newsapi.org/v2/everything?domains=wsj.com&apiKey=$newsApiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        articles = data['articles'];
        isLoading = false;
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                title: Text(article['title']),
                subtitle: Text(article['description']),
                leading: article['urlToImage'] != null
                    ? Image.network(
                        article['urlToImage'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : SizedBox.shrink(),
                onTap: () {
                  if (article['url'] != null) {
                    launchURL(article['url']);
                  }
                },
              );
            },
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchNews,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
