import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

class Settings_Sos_Screen extends StatefulWidget {
  const Settings_Sos_Screen({Key? key}) : super(key: key);

  @override
  State<Settings_Sos_Screen> createState() => _Settings_Sos_ScreenState();
}

class _Settings_Sos_ScreenState extends State<Settings_Sos_Screen> {
  List<Contact> _selectedContacts = [];
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _showContactSelection = false;
  bool _loading = false;
  bool _isDeleteMode = false;

  final TextEditingController _searchController = TextEditingController();
  Box? contactsBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _initializeHive() async {
    contactsBox = await Hive.openBox('emergency_contacts');
    _loadSavedContacts();

    if (_selectedContacts.isEmpty) {
      _fetchContacts();
    } else {
      _checkAndPrepareAllContacts();
    }
  }

  void _loadSavedContacts() {
    if (contactsBox == null) return;
    final saved = contactsBox!.get('contacts', defaultValue: []);
    if (saved.isNotEmpty) {
      setState(() {
        _selectedContacts =
            saved.map<Contact>((c) {
              return Contact(
                id: c['id'] as String? ?? '',
                displayName: c['displayName'] as String? ?? '',
                phones:
                    (c['phones'] as List<dynamic>)
                        .map(
                          (p) => Phone(
                            p['value'] as String? ?? '',
                            label: PhoneLabel.mobile,
                          ),
                        )
                        .toList(),
              );
            }).toList();
      });
    }
  }

  Future<void> _fetchContacts() async {
    setState(() => _loading = true);
    PermissionStatus permissionStatus = await Permission.contacts.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.contacts.request();
    }

    if (permissionStatus.isGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      setState(() {
        _allContacts = contacts;
        _filteredContacts = _allContacts;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contacts permission denied. Please allow it in settings.',
          ),
        ),
      );
    }
  }

  Future<void> _checkAndPrepareAllContacts() async {
    PermissionStatus permissionStatus = await Permission.contacts.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.contacts.request();
    }

    if (permissionStatus.isGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      setState(() {
        _allContacts = contacts;
        _filteredContacts = _allContacts;
      });
    }
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts =
          _allContacts
              .where(
                (contact) => contact.displayName.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  void _toggleContactSelection() {
    setState(() {
      _showContactSelection = !_showContactSelection;
      _isDeleteMode = false; // exit delete mode if switching screens
    });
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
    });
  }

  void _saveSelectedContacts() {
    if (contactsBox == null) return;

    final contactsToSave =
        _selectedContacts.map((c) {
          return {
            'id': c.id,
            'displayName': c.displayName,
            'phones':
                c.phones.map((p) {
                  String number = p.number.trim();
                  if (number.startsWith('03')) {
                    number = '+92' + number.substring(1);
                  }
                  return {'value': number};
                }).toList(),
          };
        }).toList();

    contactsBox!.put('contacts', contactsToSave);
    setState(() {
      _showContactSelection = false;
      _isDeleteMode = false;
    });
  }

  void _deleteContact(String id) {
    setState(() {
      _selectedContacts.removeWhere((c) => c.id == id);
    });

    if (contactsBox == null) return;

    final contactsToSave =
        _selectedContacts.map((c) {
          return {
            'id': c.id,
            'displayName': c.displayName,
            'phones': c.phones.map((p) => {'value': p.number}).toList(),
          };
        }).toList();
    contactsBox!.put('contacts', contactsToSave);
  }

  Widget _buildSelectedContactsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saved Emergency Contacts",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_selectedContacts.isEmpty)
          const Center(
            child: Text(
              "No contacts saved yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          ..._selectedContacts.map((contact) {
            String phone =
                contact.phones.isNotEmpty
                    ? contact.phones.first.number
                    : 'No phone';
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(contact.displayName),
              subtitle: Text(phone),
              trailing:
                  _isDeleteMode
                      ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteContact(contact.id),
                      )
                      : null,
            );
          }).toList(),
      ],
    );
  }

  Widget _buildContactSelectionList() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search Contacts',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      bool isSelected = _selectedContacts.any(
                        (c) => c.id == contact.id,
                      );
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(contact.displayName),
                        subtitle: Text(
                          contact.phones.isNotEmpty
                              ? contact.phones.first.number
                              : 'No phone',
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedContacts.add(contact);
                              } else {
                                _selectedContacts.removeWhere(
                                  (c) => c.id == contact.id,
                                );
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
        ),
        ElevatedButton.icon(
          onPressed: _saveSelectedContacts,
          icon: const Icon(Icons.save),
          label: const Text('Save Selected'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor:
                Colors.purple, // Use a fixed color that works in both themes
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Settings'),
        actions: [
          if (!_showContactSelection)
            IconButton(
              icon: Icon(_isDeleteMode ? Icons.close : Icons.edit),
              onPressed: _toggleDeleteMode,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _showContactSelection
                ? _buildContactSelectionList()
                : _buildSelectedContactsView(),
      ),
      floatingActionButton:
          _showContactSelection
              ? null
              : FloatingActionButton(
                onPressed: _toggleContactSelection,
                backgroundColor: Colors.purple,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              ),
    );
  }
}
