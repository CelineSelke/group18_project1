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
        '/shoppingList': (context) => const ShoppingList()
      },
    ),
  );
}

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  _RootWidgetState createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const RecipeBook(title: 'Recipe Book'),
    const FavoriteList(),
    const MealPlanner(title: 'Meal Planner'),
    const ShoppingList()
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
            onPressed: () => onTabTapped(1), 
            icon: Icon(Icons.favorite, 
                color: currentIndex == 1 ? Colors.amber : Colors.white, 
                size: 35)
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, 
                color: currentIndex == 2 ? Colors.amber : Colors.white, 
                size: 35),
            onPressed: () => onTabTapped(2),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, 
                color: currentIndex == 3 ? Colors.amber : Colors.white, 
                size: 35),
            onPressed: () => onTabTapped(3),
          ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("Ingredients", style: TextStyle(fontSize: 28)),),
                SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe[DatabaseHelper.columnIngredients]
                      .split(',') 
                      .map<Widget>((ingredient) => Text(
                            '• ${ingredient.trim()}',
                            style: TextStyle(fontSize: 16),
                          ))
                      .toList(),
                ),
                SizedBox(height: 12),
                Center(child: Text("Directions", style: TextStyle(fontSize: 28))),
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

  Future<void> _refreshRecipes() async {
    final updatedRecipes = await dbHelper.queryAllRecipes();
    setState(() {
      _recipesFuture = Future.value(updatedRecipes);
    });
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
                
                return _RecipeListView(recipes: filteredRecipes, onRefresh: _refreshRecipes);
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

  Future<void> _refreshRecipes() async {
    final updatedRecipes = await dbHelper.queryAllRecipes();
    setState(() {
      _recipesFuture = Future.value(updatedRecipes);
    });
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
                
                return _RecipeListView(recipes: filteredRecipes, onRefresh: _refreshRecipes);
              },
            ),
     
    );
  }
}

class _RecipeListView extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;
  final VoidCallback onRefresh;

  const _RecipeListView({required this.recipes, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _RecipeCard(recipe: recipe, onFavoriteChanged: onRefresh);
      },
    );
  }
}


class _RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onFavoriteChanged;
  const _RecipeCard({required this.recipe, required this.onFavoriteChanged});

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  late bool _isFavorite;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe[DatabaseHelper.columnFavorite] == 1;
    _initializeDb();
  }

  Future<void> _initializeDb() async {
    await _dbHelper.init();
  }

  Future<void> _toggleFavorite() async {
    final newValue = !_isFavorite;
    
    try {
      await _dbHelper.updateFavoriteStatus(
        widget.recipe[DatabaseHelper.columnId],
        newValue ? 1 : 0
      );
      
      setState(() {
        _isFavorite = newValue;
      });
      
      widget.onFavoriteChanged();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite status'))
      );
    }
  }

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
            widget.recipe[DatabaseHelper.columnTitle],
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "Cook Time: ${widget.recipe[DatabaseHelper.columnCookTime]}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(Icons.favorite, color: _isFavorite ? Colors.pink : Colors.white, size: 50)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => RecipeDetail(title: widget.recipe[DatabaseHelper.columnTitle], recipe: widget.recipe)
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
          image: AssetImage('assets/images/${widget.recipe[DatabaseHelper.columnImageURL]}'),
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
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _recipesFuture = _initializeData();
    _loadMealsForWeek(); 
    
  }

  Future<List<Map<String, dynamic>>> _initializeData() async {
    await dbHelper.init();
    return dbHelper.queryAllRecipes();
  }

  void _loadMealsForWeek() async {
    final daysInWeek = _getDaysInWeek(_currentDate);
    for (var date in daysInWeek) {
      final meals = await getMealsForDay(date);
      setState(() {
        _items[date] = meals; 
      });
    }
  }

  Future<List<String>> getMealsForDay(DateTime date) async {
    List<String> items = [];
    final plans = await dbHelper.getRecipesForDay(DateFormat('yyyy-MM-dd').format(date));
    for (var plan in plans) {
      final title = await dbHelper.getTitleFromID(plan[DatabaseHelper.columnRecipeId]);
      items.add(title);
    }
    return items;
  }

  List<DateTime> _getDaysInWeek(DateTime date) {
    final firstDay = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => firstDay.add(Duration(days: index)));
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: offset * 7));
      _loadMealsForWeek(); 
    });
  }

  void _showMealPlanDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Select a Recipe for ${DateFormat('EEEE').format(date)}', textAlign: TextAlign.center),
        children: [
          SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
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

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage('assets/images/${recipe[DatabaseHelper.columnImageURL]}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              recipe[DatabaseHelper.columnTitle],
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              _addItem(date, recipe);
                            },
                            icon: Icon(Icons.library_add),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addItem(DateTime date, Map<String, dynamic> recipe) async {
    int recipeID = recipe[DatabaseHelper.columnId];
    String day = DateFormat('yyyy-MM-dd').format(date);

    await dbHelper.insertMealPlan(recipeID, day);

    setState(() {
      _items[date] = [..._items[date] ?? [], recipe[DatabaseHelper.columnTitle]];
    });
  }

  Future<int> _getRecipeIdByTitle(String title) async {
    final recipes = await dbHelper.queryAllRecipes();
    final recipe = recipes.firstWhere((recipe) => recipe[DatabaseHelper.columnTitle] == title);
    return recipe[DatabaseHelper.columnId];
  }

  void _removeItem(DateTime date, String recipeTitle) async {
    final recipe = _items[date]?.firstWhere(
      (item) => item == recipeTitle,
    );

    if (recipe != null) {
      final recipeId = await _getRecipeIdByTitle(recipeTitle);

      await dbHelper.deleteMealPlan(DateFormat('yyyy-MM-dd').format(date), recipeId);

      setState(() {
        _items[date]?.remove(recipeTitle);
      });
    }
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
    final daysInWeek = _getDaysInWeek(_currentDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF105068),
        title: Text("Meal Planner", style: TextStyle(color: Colors.white)),
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
                      onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ); 
                        if (pickedDate != null) {
                          setState(() {
                            _currentDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
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
                          onPressed: () => _showMealPlanDialog(date),
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
                                    _removeItem(date, item);
                                  });
                                },
                              ),
                            )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShoppingList extends StatefulWidget {

  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

  class IngredientParser {
    static final _quantityRegex = RegExp(r'^\s*((?:\d+\s+\d+\/\d+|\d+\/\d+|\d+\.?\d*|\.\d+))\s*([a-zA-Z].*)?$', caseSensitive: false);
    
    static ParsedIngredient? parse(String ingredient) {
      try {
        final parts = ingredient.split(RegExp(r'\s*x\s*', caseSensitive: false));
        if (parts.length != 2) return null;

        final name = parts[0].trim();
        final quantityUnit = parts[1].trim();
        
        final match = _quantityRegex.firstMatch(quantityUnit);
        if (match == null) return null;

        final quantityStr = match.group(1);
        final unit = match.group(2)?.trim() ?? '';

        if (quantityStr == null) return null;

        final quantity = double.tryParse(quantityStr) ?? 0.0;


        return ParsedIngredient(
          name: name,
          quantity: quantity,
          unit: unit,
        );
      } catch (e) {
        return null;
      }
    }
  }

  class ParsedIngredient {
    final String name;
    final double quantity;
    final String unit;

    ParsedIngredient({
      required this.name,
      required this.quantity,
      required this.unit,
    });
  }

  class _ShoppingListState extends State<ShoppingList> {
    final DatabaseHelper _dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> _ingredients = [];

    @override
    void initState() {
      super.initState();
      _loadIngredients();
    }

    String _formatQuantity(double quantity) {
    
    return quantity.toStringAsFixed(2);
  }

    Future<void> _loadIngredients() async {
      try {
      await _dbHelper.init();
      final mealPlans = await _dbHelper.getAllMealPlans();
      final ingredientsMap = <String, ParsedIngredient>{};

      for (final mealPlan in mealPlans) {
        final recipe = await _dbHelper.getRecipeById(mealPlan[DatabaseHelper.columnRecipeId]);
        if (recipe == null) {
          continue;
        }

        final ingredientsString = recipe[DatabaseHelper.columnIngredients];
        final ingredients = ingredientsString
          .split(',')
          .toList();


        for (final ingredient in ingredients) {
          final parsed = IngredientParser.parse(ingredient);
          if (parsed == null) {
            continue;
          }


          final key = '${parsed.name} (${parsed.unit})';
          if (ingredientsMap.containsKey(key)) {
            ingredientsMap[key] = ParsedIngredient(
              name: parsed.name,
              quantity: ingredientsMap[key]!.quantity + parsed.quantity,
              unit: parsed.unit,
            );
          } else {
            ingredientsMap[key] = parsed;
          }
        }
      }

      setState(() {
        _ingredients = ingredientsMap.entries.map((entry) {
          final parsed = entry.value;
          return {
            'name': parsed.name,
            'quantity': '${_formatQuantity(parsed.quantity)} ${parsed.unit}',
            'checked': false
          };
        }).toList().cast<Map<String, dynamic>>();
      });
      } catch (e) {
        print(e);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF105068),
          title: Text("Shopping List", style: TextStyle(color:Colors.white)),
        ),
        body: _ingredients.isEmpty 
        ? SizedBox.expand(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Please add recipes into your meal planner to generate a shopping list.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _ingredients.length,
          itemBuilder: (context, index) {
            final ingredient = _ingredients[index];
            return CheckboxListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(ingredient['name']),
                  ),
                  Text(
                    ingredient['quantity'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              value: ingredient['checked'],
              onChanged: (bool? value) {
                setState(() {
                  _ingredients[index]['checked'] = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Color(0xFF105068),
            );
          },
        ),
      );
    }
  }