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
      home: const RecipeBook(title: 'Recipe Book'),
      routes: {
        '/recipeBook': (context) => const RecipeBook(title: 'Recipes'),
      },
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              //DOESN'T WORK WILL FIX LATER
              final currentRoute = ModalRoute.of(context)?.settings.name;
              if (currentRoute != '/recipeBook') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/recipeBook',
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: Icon(Icons.search, color: Colors.white, size: 35),
          ),
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

class RecipeDetail extends StatefulWidget {
  const RecipeDetail({super.key, required this.title, required this.recipe});
  final Map<String, dynamic> recipe;
  final String title;

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF105068),
        title: Text(widget.title, style: TextStyle(color:Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                Container(
                  width: 120, 
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage('assets/images/${recipe[DatabaseHelper.columnImageURL]}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe[DatabaseHelper.columnTitle], style: TextStyle(fontSize: 24)),
                      Text("Cook Time: ${recipe[DatabaseHelper.columnCookTime]}", style: TextStyle(fontSize: 20))
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Ingredients", style: TextStyle(fontSize: 28)),
                SizedBox(height: 4),
                Text(recipe[DatabaseHelper.columnIngredients], style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                Text("Directions", style: TextStyle(fontSize: 28)),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(recipe[DatabaseHelper.columnInstructions], style: TextStyle(fontSize: 16)),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}

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
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => RecipeDetail(title: recipe[DatabaseHelper.columnTitle], recipe: recipe)
            ));
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
