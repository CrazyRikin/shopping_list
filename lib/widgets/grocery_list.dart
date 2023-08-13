import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> groceryItems = [];

  @override
  void initState() {
    loadScreen();
    super.initState();
  }

  void loadScreen() async {
    final url = Uri.https(
        'fir-ecf65-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      groceryItems = loadedItems;
    });
  }

  void addItem() async {
    final newItem = await Navigator.push<GroceryItem>(
        context, MaterialPageRoute(builder: (ctx) => const NewItem()));
    loadScreen();
  }

  @override
  Widget build(BuildContext context) {
    Widget content =
        const Center(child: Text('Please add some items in the list!'));
    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: ((context, index) => Dismissible(
              onDismissed: (direction) => setState(() async {
                final indexofdeletingitem =
                    groceryItems.indexOf(groceryItems[index]);
                final url = Uri.https('fir-ecf65-default-rtdb.firebaseio.com',
                    'shopping-list/${groceryItems[index].id}.json');
                final response = await http.delete(url);
                setState(() {
                  groceryItems.remove(groceryItems[index]);
                });
                if (response.statusCode >= 400) {
                  setState(() {
                    groceryItems.insert(
                        indexofdeletingitem, groceryItems[index]);
                  });
                }
              }),
              key: ValueKey(groceryItems[index].id),
              child: Card(
                color: groceryItems[index].category.color.withOpacity(0.07),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(groceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: groceryItems[index].category.color,
                  ),
                  trailing: Text(groceryItems[index].quantity.toString()),
                ),
              ),
            )),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: addItem, icon: const Icon(Icons.add))],
        title: const Text('GROCERY LIST!'),
      ),
      body: content,
    );
  }
}
