import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? enteredName;
    int? enteredQuantity;
    var selectedCategory = categories[Categories.other];
    void saveItem() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        final url = Uri.https(
            'fir-ecf65-default-rtdb.firebaseio.com', 'shopping-list.json');
        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': enteredName!,
              'quantity': enteredQuantity!,
              'category': selectedCategory!.title
            }));
        print(response.body);
        print(response.statusCode);
        if (!context.mounted) {
          return;
        }
        Navigator.pop(context);
        // Navigator.pop(
        //     context,
        //     GroceryItem(
        //         id: DateTime.now().toString(),
        //         name: enteredName!,
        //         quantity: enteredQuantity!,
        //         category: selectedCategory!));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD NEW ITEM'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length == 1 ||
                        value.trim().length > 50) {
                      return 'Please give correct entry!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    enteredName = value;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(label: Text('Quantity')),
                        initialValue: '1',
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Give valid positive number !';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: selectedCategory,
                          items: [
                            for (final category in categories.entries)
                              DropdownMenuItem(
                                  value: category.value,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        color: category.value.color,
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(category.value.title),
                                    ],
                                  ))
                          ],
                          onChanged: (value) {
                            selectedCategory = value!;
                          }),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          formKey.currentState!.reset();
                        },
                        child: const Text('RESET')),
                    ElevatedButton(
                        onPressed: saveItem, child: const Text('ADD ITEM')),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
