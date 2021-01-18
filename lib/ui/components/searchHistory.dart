import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:songtube/provider/configurationProvider.dart';

class SearchHistoryList extends StatefulWidget {
  final Function(String) onItemTap;
  final String searchQuery;
  SearchHistoryList({
    @required this.onItemTap,
    this.searchQuery = ""
  });

  @override
  _SearchHistoryListState createState() => _SearchHistoryListState();
}

class _SearchHistoryListState extends State<SearchHistoryList> {

  http.Client client;

  @override
  void initState() {
    client = http.Client();
    super.initState();
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    List<String> searchHistory = [];
    return FutureBuilder(
      future: widget.searchQuery != "" ? client.get(
        'http://suggestqueries.google.com/complete/search?client=firefox&q=${widget.searchQuery}',
        headers: {
          'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            '(KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
          'accept-language': 'en-US,en;q=1.0',
        }
      ) : null,
      builder: (context, AsyncSnapshot<http.Response> suggestions) {
        searchHistory.clear();
        if (suggestions.hasData && widget.searchQuery != "") {
          var map = jsonDecode(suggestions.data.body);
          var mapList = map[1];
          mapList.forEach((result) {
            searchHistory.add(result);
          });
        }
        searchHistory.addAll(config.getSearchHistory());
        return ListView.builder(
          itemExtent: 40,
          itemCount: searchHistory.length,
          itemBuilder: (context, index) {
            String item = searchHistory[index];
            return ListTile(
              title: Text(
                "$item",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontSize: 14
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              leading: SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.search,
                  color: Theme.of(context).iconTheme.color),
              ),
              trailing: IconButton(
                icon: Icon(Icons.clear, size: 20),
                onPressed: () {
                  config.removeStringfromSearchHistory(index);
                },
              ),
              onTap: () => widget.onItemTap(item),
            );
          },
        );
      },
    );
  }
}