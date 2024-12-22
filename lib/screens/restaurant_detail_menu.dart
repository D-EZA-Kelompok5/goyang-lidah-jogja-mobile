// lib/screens/restaurant_detail_menu.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/announcement.dart';
import 'package:goyang_lidah_jogja/screens/menu_create_edit.dart';
import 'package:goyang_lidah_jogja/widgets/left_drawer.dart';
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
  String _announcementFilter = 'all';
  Restaurant? _restaurant;
  List<MenuElement> _menus = [];
  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _restaurantService = RestaurantService(request);
    _loadData();
    _loadAnnouncements();
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
      drawer: LeftDrawer(onWishlistChanged: () => {_refreshData}),
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
                  _buildAnnouncementSection(),
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
                // print('Error in FutureBuilder: ${snapshot.error}');
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
                  childAspectRatio: 0.8,
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
    Widget menuContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap the image in a Container with fixed height instead of AspectRatio
        Container(
          height: 160, // Fixed height for image container
          width: double.infinity,
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
        // Wrap content in Expanded to allow flexible sizing
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use minimum space needed
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
                Expanded(
                  child: Text(
                    menu.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
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
        ),
      ],
    );

    return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showMenuDetail(menu),
          child: menuContent,
        ));
  }

  // Add this new method to show the detailed popup
  void _showMenuDetail(MenuElement menu) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Menu Image
                if (menu.image != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(menu.image!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),

                // Menu Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              menu.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'Rp ${menu.price.toString()}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        menu.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons - Only visible to owners
                      if (widget.isOwner) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _navigateToMenuForm(menu: menu);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteMenu(menu);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.delete),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Close button for non-owners
                      if (!widget.isOwner)
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  List<Announcement> _getSortedAnnouncements() {
    List<Announcement> sorted = List.from(_announcements);
    switch (_announcementFilter) {
      case 'newest':
        sorted.sort((a, b) => (b.pk ?? 0).compareTo(a.pk ?? 0));
        break;
      case 'oldest':
        sorted.sort((a, b) => (a.pk ?? 0).compareTo(b.pk ?? 0));
        break;
      default:
        // 'all'
        break;
    }
    return sorted;
  }

  Widget _buildAnnouncementFilterDropdown() {
    return DropdownButton<String>(
      value: _announcementFilter,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _announcementFilter = newValue;
          });
        }
      },
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Announcements')),
        DropdownMenuItem(value: 'newest', child: Text('Newest First')),
        DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
      ],
    );
  }

  Widget _buildAnnouncementSection() {
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildAnnouncementFilterDropdown(),
                  if (widget.isOwner)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showCreateAnnouncementDialog(null),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_announcements.isEmpty)
            const Text('No announcements available.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _getSortedAnnouncements().length,
              itemBuilder: (context, index) {
                final announcement = _getSortedAnnouncements()[index];
                return Card(
                  child: ListTile(
                    title: Text(announcement.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(announcement.message)],
                    ),
                    trailing: widget.isOwner
                        ? IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () =>
                                _showAnnouncementOptions(announcement, index),
                          )
                        : null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAnnouncementOptions(Announcement announcement, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Announcement'),
            onTap: () {
              Navigator.pop(context);
              _showCreateAnnouncementDialog(announcement);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Announcement',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteAnnouncement(announcement, index);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnouncement(Announcement announcement, int index) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Announcement'),
          content:
              Text('Are you sure you want to delete "${announcement.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirmed ?? false) {
        await _restaurantService.deleteAnnouncement(announcement.pk!);
        setState(() {
          _announcements.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting announcement: $e')),
      );
    }
  }

  void _showCreateAnnouncementDialog(Announcement? announcement) {
    var titleController =
        TextEditingController(text: announcement?.title ?? '');
    var messageController =
        TextEditingController(text: announcement?.message ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            announcement != null ? 'Edit Announcement' : 'Create Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final data = {
                'title': titleController.text,
                'message': messageController.text,
              };
              try {
                if (announcement != null) {
                  await _restaurantService.updateAnnouncement(
                      announcement.pk!, data);
                } else {
                  await _restaurantService.createAnnouncement(
                      widget.restaurantId, data);
                }
                if (mounted) {
                  Navigator.pop(context);
                  await _loadAnnouncements();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${announcement != null ? 'Updated' : 'Created'} announcement successfully')),
                  );
                }
              } catch (e) {
                // print('Error ${announcement != null ? 'updating' : 'creating'} announcement: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Error ${announcement != null ? 'updating' : 'creating'} announcement: $e')),
                  );
                }
              }
            },
            child: Text(announcement != null ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }
}
