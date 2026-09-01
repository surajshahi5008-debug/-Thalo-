import 'package:flutter/material.dart';
import '../widgets/lang_bar.dart';
import '../widgets/calendar_picker.dart';

class HomeScreen extends StatefulWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;
  final Function(String) onNotificationTap;
  final String selectedDate;
  final VoidCallback onCalendarTap;
  final VoidCallback onLogout;

  const HomeScreen({
    Key? key,
    required this.currentLang,
    required this.onLanguageChanged,
    required this.onNotificationTap,
    required this.selectedDate,
    required this.onCalendarTap,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _posts = [
    {
      'username': 'सुराज शाही',
      'handle': '@surajshahi',
      'time': '२ घण्टा अगाडि',
      'content': 'मेरो आफ्नै नेपाली सामाजिक सञ्जाल एप "थलो (Thalo)" को काम गर्दैछु!',
      'likes': 15,
      'comments': 4,
    },
  ];

  final TextEditingController _postController = TextEditingController();

  void _addNewPost() {
    if (_postController.text.trim().isEmpty) return;
    setState(() {
      _posts.insert(0, {
        'username': 'सुराज शाही',
        'handle': '@surajshahi',
        'time': 'भर्खरै',
        'content': _postController.text.trim(),
        'likes': 0,
        'comments': 0,
      });
      _postController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LanguageBar(
              currentLang: widget.currentLang,
              onLanguageChanged: widget.onLanguageChanged,
              onNotificationTap: widget.onNotificationTap,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'गृह पृष्ठ (Home)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CalendarPickerWidget(
                    selectedDate: widget.selectedDate,
                    onCalendarTap: widget.onCalendarTap,
                  ),
                ],
              ),
            ),
            // नयाँ पोस्ट लेख्ने बक्स
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: const InputDecoration(
                        hintText: 'तपाईको मनमा के छ लेख्नुहोस्...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addNewPost,
                    child: const Text('पोस्ट'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // पोस्टहरूको सूची
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(child: Icon(Icons.person, size: 18)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(post['handle'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              Text(post['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(post['content']),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                                label: Text('${post['likes']}'),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                label: Text('${post['comments']}'),
                              ),
                            ],
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
  }
}
