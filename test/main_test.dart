import 'package:flutter/material.dart';
import 'models/store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '搜索测试',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SearchTestPage(),
    );
  }
}

class SearchTestPage extends StatefulWidget {
  const SearchTestPage({Key? key}) : super(key: key);

  @override
  State<SearchTestPage> createState() => _SearchTestPageState();
}

class _SearchTestPageState extends State<SearchTestPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Store> searchResults = [];

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }
    
    setState(() {
      searchResults = StoreData.searchStores(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '输入店铺名称...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _performSearch();
              },
            ),
            const SizedBox(height: 16),
            Text('搜索结果: ${searchResults.length} 个'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final store = searchResults[index];
                  return ListTile(
                    title: Text(store.name),
                    subtitle: Text('${store.floor}楼, ID: ${store.id}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
