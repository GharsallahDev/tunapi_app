import 'package:flutter/material.dart';
import '../models/image_data.dart';
import '../services/image_service.dart';
import '../widgets/grid_image.dart';
import 'upload_page.dart';

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  late Future<List<ImageData>> list;
  List<ImageData> _searchList = [];
  List<ImageData> auxList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _search = false;

  @override
  void initState() {
    super.initState();
    list = loadImages();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _search = false;
        _searchList = [];
      } else {
        _search = true;
        _searchList = auxList
            .where((image) => image.className
                .toLowerCase()
                .startsWith(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("TunApi"),
        bottom: getSearchBar(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            right: 30,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: "addImage",
              backgroundColor: const Color(0xFFF9C901),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Upload()));
              },
            ),
          ),
          Positioned(
            left: 30,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: "refreshImages",
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.refresh),
              onPressed: refreshImages,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<ImageData>>(
          future: list,
          builder:
              (BuildContext context, AsyncSnapshot<List<ImageData>> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator(
                  backgroundColor: Colors.deepPurpleAccent);
            }
            return _search
                ? buildGridView(_searchList)
                : buildGridView(auxList = snapshot.data ?? []);
          },
        ),
      ),
    );
  }

  void refreshImages() {
    setState(() {
      list = loadImages(); // Re-fetch the images from the database
    });
  }

  Widget buildGridView(List<ImageData> images) {
    return RefreshIndicator(
      onRefresh: () async {
        refreshImages();
      },
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        children: images.map((image) {
          return GridImage(uri: image.url, pre: image.className);
        }).toList(),
      ),
    );
  }

  PreferredSizeWidget getSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: ListTile(
            trailing: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _onSearchChanged();
              },
            ),
            title: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                  hintText: 'Search Class Name', border: InputBorder.none),
            ),
          ),
        ),
      ),
    );
  }
}