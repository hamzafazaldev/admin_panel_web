import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Property {
  File? imageFile;
  String? imageUrl;
  String title;
  String description;
  String location;
  double price;

  Property({
    this.imageFile,
    this.imageUrl,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
  });
}

class PropertiesView extends StatefulWidget {
  const PropertiesView({super.key});

  @override
  State<PropertiesView> createState() => _PropertiesViewState();
}

class _PropertiesViewState extends State<PropertiesView> {
  final List<Property> properties = [
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Cozy Apartment',
      description: 'A cozy apartment in the city center.',
      location: 'Downtown',
      price: 120000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
    Property(
      imageFile: null,
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Spacious Villa',
      description: 'A spacious villa with a beautiful garden.',
      location: 'Suburbs',
      price: 350000,
    ),
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    if (kIsWeb) {
      // Image picking not supported on web
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image picking is not supported on Web')),
      );
      return;
    }
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        properties[index].imageFile = File(pickedFile.path);
        properties[index].imageUrl = null;
      });
    }
  }

  void _editProperty(int index) {
    final property = properties[index];
    final titleController = TextEditingController(text: property.title);
    final descriptionController = TextEditingController(text: property.description);
    final locationController = TextEditingController(text: property.location);
    final priceController = TextEditingController(text: property.price.toString());
    final imageUrlController = TextEditingController(text: property.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Property'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (kIsWeb)
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    onChanged: (value) {
                      properties[index].imageUrl = value;
                      properties[index].imageFile = null;
                    },
                  )
                else
                  GestureDetector(
                    onTap: () => _pickImage(index),
                    child: Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: property.imageFile != null
                          ? Image.file(property.imageFile!, fit: BoxFit.cover)
                          : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  properties[index] = Property(
                    imageFile: property.imageFile,
                    imageUrl: property.imageUrl,
                    title: titleController.text,
                    description: descriptionController.text,
                    location: locationController.text,
                    price: double.tryParse(priceController.text) ?? property.price,
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPropertyCard(int index) {
    final property = properties[index];
    Widget imageWidget;
    if (kIsWeb) {
      if (property.imageUrl != null && property.imageUrl!.isNotEmpty) {
        imageWidget = Image.network(
          property.imageUrl!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80),
        );
      } else {
        imageWidget = const Icon(Icons.image_not_supported, size: 80);
      }
    } else {
      if (property.imageFile != null) {
        imageWidget = Image.file(
          property.imageFile!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = const Icon(Icons.image_not_supported, size: 80);
      }
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: imageWidget,
        title: Text(property.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(property.description),
            Text('Location: ${property.location}'),
            Text('Price: \$${property.price.toStringAsFixed(2)}'),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editProperty(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) => _buildPropertyCard(index),
    );
  }
}