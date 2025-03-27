import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: child!,
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AppFooter(),
              ),
            ],
          ),
        );
      },
      home: MyApp(),
    ),
  );
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Color(0xFF504887),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.search, color: Colors.white, size: 35),
          Icon(Icons.favorite, color: Colors.white, size: 35),
          Icon(Icons.calendar_month, color: Colors.white, size: 35),
          Icon(Icons.shopping_cart, color: Colors.white, size: 35),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Book',
      theme: ThemeData(
        colorScheme: ColorScheme.light(),
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
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _initializeData(); // Initialize database here
  }

  Future<List<Map<String, dynamic>>> _initializeData() async {
    await dbHelper.init();
    return dbHelper.queryAllRecipes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF105068),
        title: Text("Recipes", style: TextStyle(color:Colors.white)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return const Center(child: Text('No recipes found'));
          }
          return _RecipeListView(recipes: recipes);
        },
      ),
    );
  }
}

class _RecipeListView extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;
  const _RecipeListView({required this.recipes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _RecipeCard(recipe: recipe);
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF5d8aa6),
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: SizedBox(
        height: 80,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Transform.translate(
            offset: const Offset(0, 2),
            child: _buildImage(),
          ),
          title: Text(
            recipe[DatabaseHelper.columnTitle],
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "Cook Time: ${recipe[DatabaseHelper.columnCookTime]}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(Icons.favorite, color: Colors.red, size: 50),
          onTap: () {
            // Navigate to recipe detail page
          },
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 60, 
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/images/${recipe[DatabaseHelper.columnImageURL]}'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
