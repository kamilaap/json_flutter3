import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Setingan TabMenu
class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('SMK Negeri 4 - Mobile Apps'),
          backgroundColor: Color(0xFFC63C51), // Warna utama dari palet
        ),
        body: TabBarView(
          children: [
            BerandaTab(),
            UsersTab(),
            ProfilTab(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.group), text: 'Students'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
          labelColor: Color(0xFFC63C51),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF8C3061),
        ),
      ),
    );
  }
}

// Layout untuk Tab Beranda
class BerandaTab extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.school, 'label': 'Data Sekolah', 'color': Color(0xFF522258)},
    {'icon': Icons.book, 'label': 'Pelajaran', 'color': Color(0xFF8C3061)},
    {'icon': Icons.calendar_today, 'label': 'Kalender', 'color': Color(0xFFC63C51)},
    {'icon': Icons.event, 'label': 'Kegiatan', 'color': Color(0xFFD95F59)},
    {'icon': Icons.assignment, 'label': 'Penugasan', 'color': Color(0xFF522258)},
    {'icon': Icons.map, 'label': 'Lokasi Kampus', 'color': Color(0xFF8C3061)},
    {'icon': Icons.contact_phone, 'label': 'Kontak Guru', 'color': Color(0xFFC63C51)},
    {'icon': Icons.notifications, 'label': 'Pengumuman', 'color': Color(0xFFD95F59)},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          _buildWelcomeCard(),
          const SizedBox(height: 20.0),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of items per row
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 2, // Adjusts the height/width ratio of the grid items
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF522258), Color(0xFF8C3061)], // Gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Selamat Datang di SMK Negeri 4!',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black26,
              offset: Offset(2, 2),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        // Handle tap on the menu icon
        print('${item['label']} tapped');
      },
      child: Container(
        decoration: BoxDecoration(
          color: item['color'],
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(item['icon'], size: 30.0, color: Colors.white),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                item['label'],
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Layout untuk Tab User
class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Siswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 20.0),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserItem(user);
                      },
                    );
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari siswa...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildUserItem(User user) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        title: Text(user.firstName),
        subtitle: Text(user.email),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to the user detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(user: user),
            ),
          );
        },
      ),
    );
  }
}

// Halaman Detail Siswa
class UserDetailPage extends StatelessWidget {
  final User user;

  UserDetailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.firstName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            SizedBox(height: 20),
            Text(
              user.firstName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Layout untuk Tab Profil
class ProfilTab extends StatefulWidget {
  @override
  _ProfilTabState createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  String _fullName = 'Kamila Putri Herlambang';
  String _dateOfBirth = '12 Januari 2007';
  String _email = 'kp.herlambangp@gmail.com';
  String _address = 'Kp. Lebak Nangka';
  String _class = 'XI-PPLG 2';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://static.wikia.nocookie.net/naruto/images/7/70/Naruto_newshot.jpg/revision/latest/scale-to-width-down/1200?cb=20141107130405&path-prefix=id',
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              _fullName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              _email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Biodata',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(),
          _buildEditableField(
            'Nama Lengkap',
            _fullName,
            Icons.person,
            (newValue) {
              setState(() {
                _fullName = newValue;
              });
            },
          ),
          _buildEditableField(
            'Tanggal Lahir',
            _dateOfBirth,
            Icons.cake,
            (newValue) {
              setState(() {
                _dateOfBirth = newValue;
              });
            },
          ),
          _buildEditableField(
            'Email',
            _email,
            Icons.email,
            (newValue) {
              setState(() {
                _email = newValue;
              });
            },
          ),
          _buildEditableField(
            'Kelas',
            _class,
            Icons.class_,
            (newValue) {
              setState(() {
                _class = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String title,
    String value,
    IconData icon,
    Function(String) onEdit,
  ) {
    return GestureDetector(
      onTap: () {
        _editField(title, value, onEdit);
      },
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Row(
          children: [
            Text(value),
            SizedBox(width: 8),
            Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _editField(String title, String currentValue, Function(String) onSave) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController(text: currentValue);
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new $title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}


// User class to parse JSON data
class User {
  final String firstName;
  final String email;
  final String avatarUrl;

  User({
    required this.firstName,
    required this.email,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      email: json['email'],
      avatarUrl: json['avatar'],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TabScreen(),
  ));
}
