import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RecipeBook(title: 'Recipe Book'),
    );
  }
}

/* Recipe Detail Implementation Kinda
class RecipeDetail extends StatefulWidget {
  const RecipeDetail({super.key, required this.title});

  final String title;

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  

}
*/

class RecipeBook extends StatefulWidget {
  const RecipeBook({super.key, required this.title});

  final String title;

  @override
  State<RecipeBook> createState() => _RecipeBookState();
}

class _RecipeBookState extends State<RecipeBook> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<void> _initDbFuture; // Add this line

  @override
  void initState() {
    super.initState();
    _initDbFuture = dbHelper.init(); // Initialize database here
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF105068),
        title: Text("Recipes", style: TextStyle(color:Colors.white)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _initDbFuture.then((_) => dbHelper.queryAllRecipes()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No recipes found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final recipe = snapshot.data![index];
              return Card(
                color: Color(0xFF5d8aa6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                margin: EdgeInsets.all(8),
                child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    title: Text(
                      recipe[DatabaseHelper.columnTitle],
                      style: TextStyle(color: Colors.white)
                    ),
                    subtitle: Text(""),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to recipe detail page
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
