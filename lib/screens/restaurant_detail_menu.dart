// lib/screens/restaurant_detail_menu.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/screens/menu_create_edit.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/menu.dart';
import '../services/restaurant_service.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailPage({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  late RestaurantService _restaurantService;
  String _menuFilter = 'all';
  String _announcementFilter = 'all';
  Restaurant? _restaurant;
  List<MenuElement> _menus = [];

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _restaurantService = RestaurantService(request);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final restaurant =
          await _restaurantService.fetchRestaurantDetail(widget.restaurantId);
      final menus = await _restaurantService.fetchRestaurantMenus(
          widget.restaurantId, _menuFilter);

      if (mounted) {
        setState(() {
          _restaurant = restaurant;
          _menus = menus;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<void> _deleteMenu(MenuElement menu) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Menu Item'),
          content: Text('Are you sure you want to delete "${menu.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed ?? false) {
        await _restaurantService.deleteMenu(menu.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu item deleted successfully')),
          );
          _refreshData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting menu: $e')),
        );
      }
    }
  }

  Future<void> _navigateToMenuForm({MenuElement? menu}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuFormPage(
          restaurantId: widget.restaurantId,
          menu: menu,
        ),
      ),
    );

    if (result == true) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Restaurant?>(
          future: _restaurantService.fetchRestaurantDetail(widget.restaurantId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text('Restaurant not found'),
              );
            }

            final restaurant = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRestaurantHeader(restaurant),
                  _buildMenuSection(restaurant),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToMenuForm(),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildRestaurantHeader(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: restaurant.image != null
                    ? Image.network(
                        restaurant.image!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 16),

              // Restaurant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      restaurant.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(restaurant.category),
                          backgroundColor: Colors.grey[200],
                        ),
                        Chip(
                          label: Text(
                              priceRangeValues.reverse[restaurant.priceRange]!),
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Menu Items',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildMenuFilterDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<MenuElement>>(
            future: _restaurantService.fetchRestaurantMenus(
                restaurant.id, _menuFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('Error in FutureBuilder: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No menu items found'),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final menu = snapshot.data![index];
                  return _buildMenuItem(menu);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuElement menu) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMenuOptions(menu),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Image
            AspectRatio(
              aspectRatio: 1,
              child: menu.image != null
                  ? Image.network(
                      menu.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : _buildPlaceholderImage(),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menu.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${menu.price.toString()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuOptions(MenuElement menu) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Menu'),
              onTap: () {
                Navigator.pop(context);
                _navigateToMenuForm(menu: menu);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Menu',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteMenu(menu);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuFilterDropdown() {
    return DropdownButton<String>(
      value: _menuFilter,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _menuFilter = newValue;
          });
        }
      },
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Items')),
        DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
        DropdownMenuItem(
            value: 'price_high', child: Text('Price: High to Low')),
        DropdownMenuItem(value: 'name_asc', child: Text('Name: A to Z')),
        DropdownMenuItem(value: 'name_desc', child: Text('Name: Z to A')),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
