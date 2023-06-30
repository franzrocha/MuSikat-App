import 'package:musikat_app/controllers/categories_controller.dart';
import 'package:musikat_app/utils/exports.dart';

class DescriptionSelectionScreen extends StatefulWidget {
  const DescriptionSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DescriptionSelectionScreen> createState() =>
      _DescriptionSelectionScreenState();
}

class _DescriptionSelectionScreenState
    extends State<DescriptionSelectionScreen> {
  final Map<String, bool> _checkedDescriptions = {};
  final CategoriesController _categoriesCon = CategoriesController();
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  bool showNoResults = false;

  @override
  void initState() {
    super.initState();
    _fetchDescriptions();
  }

  Future<void> _fetchDescriptions() async {
    List<String> descriptions = await _categoriesCon.getDescriptions();
    setState(() {
      for (String description in descriptions) {
        _checkedDescriptions[description] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Select a description', style: appBarStyle),
        showLogo: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                bool hasSelectedDescriptions = false;
                _checkedDescriptions.forEach((description, isSelected) {
                  if (isSelected) {
                    hasSelectedDescriptions = true;
                    _checkedDescriptions[description] = false;
                  }
                });

                if (hasSelectedDescriptions) {
                  ToastMessage.show(context, 'All descriptions removed');
                } else {
                  ToastMessage.show(
                      context, 'No descriptions selected to remove');
                }
              });
            },
            icon: const FaIcon(
              FontAwesomeIcons.trash,
              size: 20,
            ),
          ),
        ],
      ),
      backgroundColor: musikatBackgroundColor,
      body: Column(
        children: [
          searchBar(),
          descriptionChips(),
          if (showNoResults) Text('No results found', style: shortDefault),
          descriptionList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          List<String> selectedDescriptions = [];
          for (String description in _checkedDescriptions.keys) {
            if (_checkedDescriptions[description]!) {
              selectedDescriptions.add(description);
            }
          }
          if (selectedDescriptions.isEmpty) {
            ToastMessage.show(context, 'Please select a description');
          } else if (selectedDescriptions.length > 10) {
            ToastMessage.show(
                context, 'Please select a maximum of 10 descriptions');
          } else {
            Navigator.pop(context, selectedDescriptions);
          }
        },
        child: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Expanded descriptionList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _checkedDescriptions.length,
        itemBuilder: (BuildContext context, int index) {
          String description = _checkedDescriptions.keys.toList()[index];
          if (searchText.isNotEmpty &&
              !description.toLowerCase().contains(searchText)) {
            return const SizedBox.shrink();
          }
          return Container(
            color: _checkedDescriptions[description]!
                ? const Color.fromARGB(255, 10, 10, 10)
                : null,
            child: ListTile(
              onTap: () {
                setState(() {
                  _checkedDescriptions[description] =
                      !_checkedDescriptions[description]!;
                });
              },
              selected: _checkedDescriptions[description]!,
              title: Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              trailing: _checkedDescriptions[description]!
                  ? const Icon(Icons.check, color: musikatColor2)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Padding descriptionChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _checkedDescriptions.keys
              .where((description) => _checkedDescriptions[description]!)
              .map((description) => Chip(
                    deleteIconColor: Colors.white,
                    backgroundColor: musikatColor,
                    label: Text(
                      description,
                      style:
                         const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    onDeleted: () {
                      setState(() {
                        _checkedDescriptions[description] = false;
                      });
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Padding searchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 13),
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search',
          fillColor: musikatBackgroundColor,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          filled: true,
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
               showNoResults = _checkedDescriptions.keys
                .every((description) => !description.toLowerCase().contains(searchText));

          });
        },
      ),
    );
  }
}
