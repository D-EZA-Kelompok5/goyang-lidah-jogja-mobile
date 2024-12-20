import 'package:flutter/material.dart';
import '../models/wishlist.dart';
import '../services/wishlist_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class WishlistEditPage extends StatefulWidget {
  final WishlistElement wishlist;

  const WishlistEditPage({Key? key, required this.wishlist}) : super(key: key);

  @override
  _WishlistEditPageState createState() => _WishlistEditPageState();
}

class _WishlistEditPageState extends State<WishlistEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String catatan;
  late String status;

  @override
  void initState() {
    super.initState();
    catatan = widget.wishlist.catatan;
    status = widget.wishlist.status;
  }

  @override
  Widget build(BuildContext context) {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final wishlistService = WishlistService(request);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Wishlist Item'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.wishlist.menu.image.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.wishlist.menu.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                widget.wishlist.menu.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(widget.wishlist.menu.description),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: catatan,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  catatan = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'BELUM', child: Text('Belum Pernah Dibeli')),
                  DropdownMenuItem(value: 'SUDAH', child: Text('Sudah Pernah Dibeli')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        widget.wishlist.catatan = catatan;
                        widget.wishlist.status = status;

                        await wishlistService.updateWishlist(widget.wishlist);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Wishlist updated successfully.')),
                        );

                        Navigator.pop(context, true);
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update wishlist: $error')),
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
