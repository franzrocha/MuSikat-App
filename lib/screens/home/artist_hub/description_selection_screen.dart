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
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    for (String description in descriptions) {
      _checkedDescriptions[description] = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Text(
          'Select a description',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: descriptions.length,
              itemBuilder: (BuildContext context, int index) {
                String description = descriptions[index];
                if (_searchText.isNotEmpty &&
                    !description.toLowerCase().contains(_searchText)) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  onTap: () {
                    setState(() {
                      _checkedDescriptions[description] =
                          !_checkedDescriptions[description]!;
                    });
                  },
                  selected: _checkedDescriptions[description]!,
                  selectedTileColor: Colors.grey,
                  title: Text(
                    description,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  ),
                  trailing: _checkedDescriptions[description]!
                      ? const Icon(Icons.check, color: musikatColor2)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          List<String> selectedDescriptions = [];
          for (String description in descriptions) {
            if (_checkedDescriptions[description]!) {
              selectedDescriptions.add(description);
            }
          }
          if (selectedDescriptions.isEmpty) {
            ToastMessage.show(
                context, 'Please select at least one description');
          } else if (selectedDescriptions.length > 10) {
            ToastMessage.show(context, 'Please select at most 10 descriptions');
          } else {
            Navigator.pop(context, selectedDescriptions);
          }
        },
        child: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
