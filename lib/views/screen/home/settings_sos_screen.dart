import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';

class SettingsSosScreen extends StatefulWidget {
  const SettingsSosScreen({super.key});

  @override
  State<SettingsSosScreen> createState() => _SettingsSosScreenState();
}

class _SettingsSosScreenState extends State<SettingsSosScreen> {
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact> _selectedContacts = [];
  bool _loading = false;
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
    _fetchContacts();
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
    setState(() {
      _loading = true;
    });

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
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contacts permission denied. Please allow it in settings.',
          ),
        ),
      );
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts =
          _allContacts.where((c) {
            return c.displayName.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      bool exists = _selectedContacts.any((c) => c.id == contact.id);
      if (exists) {
        _selectedContacts.removeWhere((c) => c.id == contact.id);
      } else {
        _selectedContacts.add(contact);
      }
    });
    _saveSelectedContacts();
  }

  void _saveSelectedContacts() {
    if (contactsBox == null) return;
    final contactsToSave =
        _selectedContacts.map((c) {
          return {
            'id': c.id,
            'displayName': c.displayName,
            'phones':
                c.phones
                    .map((p) => {'label': 'mobile', 'value': p.number})
                    .toList(),
          };
        }).toList();

    contactsBox!.put('contacts', contactsToSave);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildContactTile(Contact contact) {
    final isSelected = _selectedContacts.any((c) => c.id == contact.id);

    return ListTile(
      leading:
          (contact.photo != null && contact.photo!.isNotEmpty)
              ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
              : CircleAvatar(
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName.substring(0, 1)
                      : '?',
                ),
              ),
      title: Text(
        contact.displayName.isNotEmpty ? contact.displayName : 'No Name',
      ),
      subtitle:
          contact.phones.isNotEmpty ? Text(contact.phones.first.number) : null,
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) {
          _toggleContactSelection(contact);
        },
      ),
      onTap: () => _toggleContactSelection(contact),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings - Emergency Contacts')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search contacts...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredContacts.isEmpty
                            ? const Center(child: Text('No contacts found'))
                            : ListView.builder(
                              itemCount: _filteredContacts.length,
                              itemBuilder: (context, index) {
                                return _buildContactTile(
                                  _filteredContacts[index],
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
