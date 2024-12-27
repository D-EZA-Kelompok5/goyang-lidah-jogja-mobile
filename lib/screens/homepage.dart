// lib/screens/homepage.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/wishlist.dart';
import 'package:goyang_lidah_jogja/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:goyang_lidah_jogja/screens/menu_detail.dart';
import 'package:goyang_lidah_jogja/widgets/left_drawer.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goyang_lidah_jogja/models/menu.dart';
import '../services/wishlist_service.dart';

class MyHomePage extends StatefulWidget {
  final UserProfile? userProfile;

  const MyHomePage({super.key, this.userProfile});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<MenuElement> allMenus = [];
  List<MenuElement> filteredMenus = [];
  Timer? _debounce;

  UserProfile? userProfile;
  bool isLoading = true;
  bool isLoadingMenus = true;
  Map<int, int> wishlistIds = {};

  late CookieRequest request;
  late WishlistService wishlistService;

  @override
  void initState() {
    super.initState();
    print("Initializing MyHomePage...");
    request = Provider.of<CookieRequest>(context, listen: false);
    wishlistService = WishlistService(request);
    
    _initializeData();
    
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print("UserProvider status: ${userProvider.isLoading}");

    // Tunggu sampai UserProvider selesai loading
    if (userProvider.isLoading) {
      userProvider.addListener(() {
        if (!userProvider.isLoading) {
          _handleUserProfileInitialization();
        }
      });
    } else {
      _handleUserProfileInitialization();
    }

    _fetchMenus();
  }

  void _handleUserProfileInitialization() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (widget.userProfile != null) {
      print("Using widget userProfile");
      setState(() {
        userProfile = widget.userProfile;
        isLoading = false;
      });
      _initializeWishlist();
    } else if (userProvider.userProfile != null) {
      print("Using provider userProfile");
      setState(() {
        userProfile = userProvider.userProfile;
        isLoading = false;
      });
      _initializeWishlist();
    } else {
      print("No user profile found");
      setState(() {
        userProfile = null;
        isLoading = false;
      });
    }
  }

  Future<void> _initializeWishlist() async {
    if (request.loggedIn) {
      try {
        List<WishlistElement> existingWishlists =
            await wishlistService.fetchWishlists(request);

        setState(() {
          wishlistIds = {
            for (var wishlist in existingWishlists) wishlist.menu.id: wishlist.id,
          };
        });
      } catch (e) {
        print('Error fetching wishlists: $e');
      }
    }
  }

  Future<void> _initializeUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (request.loggedIn) {
      try {
        // Gunakan refreshUserProfile dari provider
        await userProvider.refreshUserProfile();
        List<WishlistElement> existingWishlists = 
            await wishlistService.fetchWishlists(request);

        if (mounted) {
          setState(() {
            userProfile = userProvider.userProfile;
            wishlistIds = {
              for (var wishlist in existingWishlists) 
                wishlist.menu.id: wishlist.id,
            };
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error initializing user profile: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          userProfile = null;
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounce search to avoid too many API calls
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  void _performSearch(String query) {
    setState(() {
      isLoadingMenus = true;
    });

    if (query.isEmpty) {
      setState(() {
        filteredMenus = allMenus;
        isLoadingMenus = false;
      });
      return;
    }

    // Filter menus locally
    setState(() {
      filteredMenus = allMenus.where((menu) {
        final nameMatch = menu.name.toLowerCase().contains(query.toLowerCase());
        final descriptionMatch =
            menu.description.toLowerCase().contains(query.toLowerCase());
        final restaurantMatch =
            menu.restaurant.name.toLowerCase().contains(query.toLowerCase());
        return nameMatch || descriptionMatch || restaurantMatch;
      }).toList();
      isLoadingMenus = false;
    });
  }

  Future<void> _fetchMenus() async {
    try {
      List<MenuElement> fetchedMenus = await fetchMenus();
      setState(() {
        allMenus = fetchedMenus;
        filteredMenus = fetchedMenus; // Initially show all menus
        isLoadingMenus = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMenus = false;
      });
      print('Error fetching menus: $e');
    }
  }

  MenuItem menuElementToMenuItem(MenuElement menuElement) {
    return MenuItem(
      id: menuElement.id,
      name: menuElement.name,
      description: menuElement.description,
      price: menuElement.price.toDouble(),
      image: menuElement.image ?? '',
      restaurantName: menuElement.restaurant.name,
    );
  }

  Future<void> _toggleWishlist(MenuElement menu) async {
    try {
      //final menuItem = menuElementToMenuItem(menu);

      if (wishlistIds.containsKey(menu.id)) {
        // Jika sudah ada di wishlist, hapus
        final wishlistId = wishlistIds[menu.id]!;
        await wishlistService.deleteWishlist(wishlistId, request);

        setState(() {
          wishlistIds.remove(menu.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${menu.name} removed from wishlist.')),
        );
      } else {
        // Jika belum ada, tambah
        final wishlistId = await wishlistService.createWishlist(WishlistElement(
          id: 0,
          menu: menuElementToMenuItem(menu),
          catatan: '',
          status: 'BELUM',
        ));
        setState(() {
          wishlistIds[menu.id] = wishlistId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${menu.name} added to wishlist.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void refreshWishlist() {
    _initializeUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (isLoading || userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading..."),
                ],
              ),
            ),
          );
        }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 10),
                const Text('GoyangLidahJogja',
                    style: TextStyle(fontSize: 20, color: Colors.green)),
              ],
            ),
            const Icon(Icons.search,
                color: Colors.green), // Ikon search dengan warna
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2.0, // Bayangan ringan untuk tampilan mobile
      ),
      drawer: LeftDrawer(
          onWishlistChanged: refreshWishlist), // Pass UserProfile ke LeftDrawer
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProfile != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    userProfile!.profilePicture != null
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(userProfile!.profilePicture!),
                          )
                        : const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person, size: 30),
                          ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile!.username,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userProfile!.roleDisplay, // Menggunakan getter
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (userProfile != null) const SizedBox(height: 20),
            Center(
              child: Text(
                'Mau makan apa?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari menu...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: filteredMenus.isEmpty && !isLoadingMenus
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada menu yang ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // Nonaktifkan scroll pada GridView
                      shrinkWrap: true, // Membatasi ukuran GridView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600
                            ? 3
                            : 2, // Responsiveness
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio:
                            MediaQuery.of(context).size.width > 600
                                ? 0.8
                                : 0.75, // Responsiveness
                      ),
                      itemCount: isLoadingMenus ? 6 : filteredMenus.length,
                      itemBuilder: (context, index) {
                        if (isLoadingMenus) {
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: LinearProgressIndicator(),
                                ),
                              ],
                            ),
                          );
                        }

                        final menu = filteredMenus[index];
                        final isInWishlist = wishlistIds.containsKey(menu.id);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuDetailPage(
                                  menu: menu,
                                  wishlistService: wishlistService,
                                  wishlistIds: wishlistIds,
                                  refreshWishlist: refreshWishlist,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.network(
                                    menu.image ?? '',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: 120,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.broken_image,
                                          size: 50, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Menu name and heart icon in a Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              menu.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (userProfile?.role ==
                                              Role.CUSTOMER)
                                            GestureDetector(
                                              onTap: () =>
                                                  _toggleWishlist(menu),
                                              child: Icon(
                                                isInWishlist
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isInWishlist
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${menu.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        menu.restaurant.name,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
    },
  );
  }
}