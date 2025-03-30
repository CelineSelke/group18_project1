import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    MaterialApp(
      home: RootWidget(),
      routes: {
        '/recipeBook': (context) => const RecipeBook(title: 'Recipes'),
        '/favoritesList': (context) => const FavoriteList(),
        '/mealPlanner': (context) => MealPlanner(title: 'Meal Planner'),
      },
    ),
  );
}

class RootWidget extends StatefulWidget {
  @override
  _RootWidgetState createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const RecipeBook(title: 'Recipe Book'),
    const MealPlanner(title: 'Meal Planner'),
    const FavoriteList()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: _screens[_currentIndex],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppFooter(
              currentIndex: _currentIndex,
              onTabTapped: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Color(0xFF504887),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.search, 
                color: currentIndex == 0 ? Colors.amber : Colors.white, 
                size: 35),
            onPressed: () => onTabTapped(0),
          ),
          IconButton(
            onPressed: () => onTabTapped(2), 
            icon: Icon(Icons.favorite, 
                color: currentIndex == 2 ? Colors.amber : Colors.white, 
                size: 35)
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, 
                color: currentIndex == 1 ? Colors.amber : Colors.white, 
                size: 35),
            onPressed: () => onTabTapped(1),
          ),
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
  bool isVegetarian = false;
  bool isVegan = false;
  bool isGlutenFree = false;

  List<Map<String, dynamic>> _filterRecipes(List<Map<String, dynamic>> allRecipes) {
    return allRecipes.where((recipe) {
      bool matches = true;
      
      if (isVegetarian) {
        matches = matches && recipe[DatabaseHelper.columnVegetarian] == 1;
      }
      if (isVegan) {
        matches = matches && recipe[DatabaseHelper.columnVegan] == 1;
      }
      if (isGlutenFree) {
        matches = matches && recipe[DatabaseHelper.columnGluten] == 1;
      }
      return matches;
    }).toList();
  }


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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            color: Color(0xFFA897A7),
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              height: 135,
              width: double.infinity,
              padding: const EdgeInsets.all(16), 
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Dietary Filters', style: TextStyle(color: Colors.black, fontSize: 22)),
                  Text('Only show recipes which are...', style: TextStyle(color: Colors.black, fontSize: 16)),
                  Row(
                    children: [
                      Checkbox(
                        value: isVegetarian,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isVegetarian = newValue!;
                          });
                        },
                      ),
                      Text('Vegetarian'),
                      Checkbox(
                        value: isVegan,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isVegan = newValue!;
                          });
                        },
                      ),
                      Text('Vegan'),
                      Checkbox(
                        value: isGlutenFree,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isGlutenFree = newValue!;
                          });
                        },
                      ),
                      Text('Gluten-Free')
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final allRecipes = snapshot.data ?? [];
                final filteredRecipes = _filterRecipes(allRecipes);

                if (filteredRecipes.isEmpty) {
                  return Center(
                    child: Text(
                      allRecipes.isEmpty 
                        ? 'No recipes found' 
                        : 'No recipes match the filters',
                    ),
                  );
                }
                
                return _RecipeListView(recipes: filteredRecipes);
              },
            ),
          ),
        ]
      ),
    );
  }
}

class FavoriteList extends StatefulWidget {
  const FavoriteList({super.key});
  final String title = "Favorites";

  @override
  State<FavoriteList> createState() => _FavoriteListState();
}



class _FavoriteListState extends State<FavoriteList> {
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

  List<Map<String, dynamic>> _filterRecipes(List<Map<String, dynamic>> allRecipes) {
    return allRecipes.where((recipe) {
      bool matches = true;

      matches = matches && recipe[DatabaseHelper.columnFavorite] == 1;
      
      return matches;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF105068),
        title: Text("Favorites", style: TextStyle(color:Colors.white)),
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
                final allRecipes = snapshot.data ?? [];
                final filteredRecipes = _filterRecipes(allRecipes);

                if (filteredRecipes.isEmpty) {
                  return Center(
                    child: Text(
                      allRecipes.isEmpty 
                        ? 'No recipes found' 
                        : 'No recipes match the filters',
                    ),
                  );
                }
                
                return _RecipeListView(recipes: filteredRecipes);
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

class _FavoriteListView extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;
  final Function(DateTime, Map<String, dynamic>) onButtonPressed;
  final DateTime date;
  const _FavoriteListView({required this.recipes, required this.onButtonPressed, required this.date});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        if(recipes[index][DatabaseHelper.columnFavorite] == 1){
          return Row(children: [
            _RecipeCard(recipe: recipe), 
            IconButton(
                icon: Icon(Icons.my_library_add),
                onPressed: () {
                  onButtonPressed(date, recipe);
                },
            ),],);
        }
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
          trailing: IconButton(
            onPressed: () async {
              final newFavoriteValue = recipe[DatabaseHelper.columnFavorite] == 0 ? 1 : 0;

              await DatabaseHelper().updateFavoriteStatus(recipe[DatabaseHelper.columnId], newFavoriteValue);


            },
            icon: Icon(Icons.favorite, color: recipe[DatabaseHelper.columnFavorite] == 0 ? Colors.white : Colors.red, size: 50)
          ),
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

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key, required this.title});

  final String title;

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  late DateTime _currentDate;
  final Map<DateTime, List<String>> _items = {};
  final TextEditingController _textController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _recipesFuture;
  List<Map<String, dynamic>> _filterRecipes(List<Map<String, dynamic>> allRecipes) {
      return allRecipes.where((recipe) {
        bool matches = true;

        matches = matches && recipe[DatabaseHelper.columnFavorite] == 1;
        
        return matches;
      }).toList();
  }

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _recipesFuture = _initializeData();
  }

  Future<List<Map<String, dynamic>>> _initializeData() async {
    await dbHelper.init();
    return dbHelper.queryAllRecipes();
  }


  List<DateTime> _getDaysInWeek(DateTime date) {
    final firstDay = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => firstDay.add(Duration(days: index)));
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: offset * 7));
    });
  }

  void _showRecipeDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select a recipe for ${DateFormat('EEEE').format(date)}'),
        content: Container(
          height: 300, 
          child: Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final allRecipes = snapshot.data ?? [];
                final filteredRecipes = _filterRecipes(allRecipes);

                if (filteredRecipes.isEmpty) {
                  return Center(
                    child: Text(
                      allRecipes.isEmpty 
                        ? 'No favorites found' 
                        : 'No recipes match the filters',
                    ),
                  );
                }
                
                return _FavoriteListView(recipes: filteredRecipes, date: date, onButtonPressed: _addItem,);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _addItem(DateTime date, Map<String, dynamic> recipe) {
    setState(() {
      _items[date] = [..._items[date] ?? [], recipe[DatabaseHelper.columnTitle]];
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInWeek = _getDaysInWeek(_currentDate);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF105068),
        title: Text("Meal Planner", style: TextStyle(color:Colors.white)),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => _changeWeek(-1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [ 
                    Text(
                      '${DateFormat('MMM d').format(daysInWeek.first)} - '
                      '${DateFormat('MMM d').format(daysInWeek.last)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {},
                    ),
                  ]
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () => _changeWeek(1),
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: daysInWeek.length,
              separatorBuilder: (context, index) => Divider(height: 16),
              itemBuilder: (context, index) {
                final date = daysInWeek[index];
                final dayName = DateFormat('EEEE').format(date);
                final items = _items[date] ?? [];

                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          '$dayName, ${DateFormat('MMM d').format(date)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _showRecipeDialog(date),
                        ),
                      ),
                      if (items.isNotEmpty)
                        ...items.map((item) => ListTile(
                          title: Text(item),
                          dense: true,
                          trailing: IconButton(
                            icon: Icon(Icons.delete, size: 16),
                            onPressed: () {
                              setState(() {
                                _items[date]?.remove(item);
                              });
                            },
                          ),
                        )
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ]
      ),
    );
  }
}

