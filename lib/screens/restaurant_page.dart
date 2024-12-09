import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/restaurant.dart';
import 'package:goyang_lidah_jogja/models/user_profile.dart';
import 'package:goyang_lidah_jogja/widgets/left_drawer.dart';
import '../models/restaurant.dart';
import '../models/user_profile.dart';

class RestaurantPage extends StatelessWidget {
  RestaurantPage({super.key});

  // Sample data
  final List<Restaurant> restaurants = [
    Restaurant(
      id: 1,
      name: "Gudeg Mak Djum",
      description:
          "Experience the authentic taste of Yogyakarta with our traditional dishes and modern fusion cuisine.",
      address: "Jl. Malioboro No. 123, Yogyakarta",
      category: "Traditional",
      priceRange: PriceRange.DOLLAR,
      image:
          "https://www.philippekaltenbach.com/wp-content/uploads/2020/10/Restoran-terbaik-di-kota-Yogyakarta.jpg",
      owner: UserProfile(
        userId: 1,
        username: "owner",
        email: "owner@example.com",
        role: Role.RESTAURANT_OWNER,
        bio: "Owner of Jogja Special Restaurant",
        reviewCount: 0,
        level: Level.BEGINNER,
      ),
    ),
    // Add more sample restaurants as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Restaurants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Add the drawer here
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: restaurants.isEmpty
            ? const Center(
                child: Text(
                  'You don\'t have any restaurants yet.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      return RestaurantCard(restaurant: restaurants[index]);
                    },
                  );
                },
              ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({
    super.key,
    required this.restaurant,
  });

  String _formatPriceRange(PriceRange priceRange) {
    switch (priceRange) {
      case PriceRange.DOLLAR:
        return '\$';
      case PriceRange.DOLLAR_DOLLAR_DOLLAR:
        return '\$\$\$';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to restaurant detail page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => RestaurantDetailPage(restaurant: restaurant),
          //   ),
          // );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: restaurant.image != null
                  ? Image.network(
                      restaurant.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const PlaceholderImage();
                      },
                    )
                  : const PlaceholderImage(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      restaurant.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          restaurant.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatPriceRange(restaurant.priceRange),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'No Image',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
