// lib/screens/restaurant_detail_menu.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/announcement.dart';
import 'package:goyang_lidah_jogja/screens/menu_create_edit.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/menu.dart';
import '../services/restaurant_service.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;
  final bool isOwner;

  const RestaurantDetailPage({
    Key? key,
    required this.restaurantId,
    this.isOwner = false,
  }) : super(key: key);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  late RestaurantService _restaurantService;
  String _menuFilter = 'all';
  Restaurant? _restaurant;
  List<MenuElement> _menus = [];
  List<AnnouncementElement> _announcements = [];
  String _announcementFilter = 'newest';

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

  Future<void> _loadAnnouncements() async {
    try {
      final announcements =
          await _restaurantService.fetchAnnouncements(widget.restaurantId);
      if (mounted) {
        setState(() {
          _announcements = announcements;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading announcements: $e')),
        );
      }
    }
  }

  Future<void> _createAnnouncement() async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String message = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Announcement'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => title = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => message = value ?? '',
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.pop(context, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _restaurantService.createAnnouncement(
          widget.restaurantId,
          {'title': title, 'message': message},
        );
        await _loadAnnouncements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating announcement: $e')),
          );
        }
      }
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
                  _buildAnnouncementsSection(), // Show to all users
                  _buildMenuSection(restaurant),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.isOwner
          ? FloatingActionButton(
              onPressed: () => _navigateToMenuForm(),
              child: const Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
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
              if (widget.isOwner) _buildMenuFilterDropdown(),
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

  // Modify _buildMenuItem to handle both owner and non-owner views
  Widget _buildMenuItem(MenuElement menu) {
    Widget menuContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: widget.isOwner
          ? InkWell(
              onTap: () => _showMenuOptions(menu),
              child: menuContent,
            )
          : menuContent, // No InkWell for non-owners
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

  Widget _buildAnnouncementsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Filter dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _announcementFilter,
                      underline: Container(), // Remove the default underline
                      icon: const Icon(Icons.sort),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _announcementFilter = newValue;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Newest First'),
                        ),
                        DropdownMenuItem(
                          value: 'oldest',
                          child: Text('Oldest First'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Create button for owners
                  if (widget.isOwner)
                    ElevatedButton.icon(
                      onPressed: _createAnnouncement,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Create',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<AnnouncementElement>>(
            future: _restaurantService.fetchAnnouncements(
              widget.restaurantId,
              filter: _announcementFilter,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No announcements yet'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final announcement = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(announcement.message),
                      ),
                      // Only show edit/delete options for owners
                      trailing: widget.isOwner
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await _editAnnouncement(announcement);
                                } else if (value == 'delete') {
                                  await _deleteAnnouncement(announcement.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _editAnnouncement(AnnouncementElement announcement) async {
    final formKey = GlobalKey<FormState>();
    String title = announcement.title;
    String message = announcement.message;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Announcement'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: announcement.title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => title = value ?? '',
              ),
              TextFormField(
                initialValue: announcement.message,
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => message = value ?? '',
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _restaurantService.updateAnnouncement(
          announcement.id,
          {'title': title, 'message': message},
        );
        await _loadAnnouncements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating announcement: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteAnnouncement(int announcementId) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Announcement'),
          content:
              const Text('Are you sure you want to delete this announcement?'),
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

      // If user confirmed deletion
      if (confirmed ?? false) {
        await _restaurantService.deleteAnnouncement(announcementId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement deleted successfully')),
          );
          // Refresh the data to update the UI
          _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting announcement: $e')),
        );
      }
    }
  }
}
