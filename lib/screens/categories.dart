import 'package:flutter/material.dart';
import 'package:my_first_app/widgets/CategoryAdd.dart';
import 'package:provider/provider.dart';
import 'package:my_first_app/models/category.dart';
import 'package:my_first_app/widgets/CategoryEdit.dart';
import 'package:my_first_app/providers/CategoryProvider.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    // List<Category> categories = provider.categories;

    return Scaffold(
        appBar: AppBar(
          title: Text('Categories'),
        ),

       //UI Integration: Use FutureBuilder to handle asynchronous data fetching and errors in the UI
       //FutureBuilder is a Widget that will help you to execute some asynchronous function and based on that function’s result your UI will update.
        body: FutureBuilder<List<Category>>(
          future: provider.apiService.fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading spinner while the request is being processed
              return const Center(child: CircularProgressIndicator());

            } else if (snapshot.hasError) {
              // Show an error message if something went wrong
              return Center(child: Text('Error: ${snapshot.error}'));

            }else if (snapshot.data!.isEmpty) {
              // if that is not empty.
              return const Center(child: Text('No items added yet.'));

            } else if (snapshot.hasData) {
              // Display the list of products if the data is available
              final categories = snapshot.data!;

              return   ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {

                  Category category = categories[index];

                  return ListTile(
                    title: Text(category.name),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return CategoryEdit(
                                    category, provider.updateCategory);
                              });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Are you sure you want to delete?"),
                                  actions: [
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                        child: Text("Delete"),
                                        onPressed: () => deleteCategory(provider.deleteCategory, category)
                                    ),
                                  ],
                                );
                              });
                        },
                      )
                    ]),
                  );
                },
              );
            } else {
              // Handle the case where no data was received
              return Center(child: Text('No products available'));
            }
          },
        ),


      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return CategoryAdd(provider.addCategory);
                });
          },
          child: Icon(Icons.add)
      ),
    );
  }

  Future deleteCategory(Function callback, Category category) async {
    await callback(category);
    Navigator.pop(context);
  }

}
