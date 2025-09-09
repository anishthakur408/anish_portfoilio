import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anish Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Offset _mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePos = event.position;
          });
        },
        child: Stack(
          children: [
            // Animated Background
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPainter(_mousePos),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              child: Column(
                children: const [
                  NavBar(),
                  HeroSection(),
                  SkillsSection(),
                  ProjectSection(),
                  Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// 🎨 Background Painter for glowing cursor
class BackgroundPainter extends CustomPainter {
  final Offset mousePos;
  BackgroundPainter(this.mousePos);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white30.withOpacity(0.3),
          Colors.white12.withOpacity(0.15),
          Colors.transparent,
        ],
        radius: 0.35,
      ).createShader(Rect.fromCircle(center: mousePos, radius: 1000));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.mousePos != mousePos;
  }
}

// ---------------------- NAVBAR ----------------------
class NavBar extends StatelessWidget {
  const NavBar({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "  A K  ",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Row(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white),
                onPressed: () => _launchURL("https://github.com/anishthakur408"),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.linkedin, color: Colors.white),
                onPressed: () => _launchURL("https://www.linkedin.com/in/anish-thakur-408"),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.white),
                onPressed: () => _launchURL("https://x.com/anishthakur401"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------- HERO SECTION ----------------------
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 900;
        return Container(
          padding: const EdgeInsets.all(42),
          child: isWide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildTextContent()),
              const SizedBox(width: 200),
              Expanded(
                child: Image.asset("assets/profile.png"),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/profile.png",
                height: 250,
              ),
              const SizedBox(height: 40),
              _buildTextContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HI I'm ANISH",
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 30),
        const Text(
          "I am a Flutter & Python Developer",
          style: TextStyle(fontSize: 32, color: Colors.white70),
        ),
        const SizedBox(height: 16),
        const Text(
          "I build modern apps using Flutter and Python. Passionate about crafting smooth UI, writing clean code, and solving real-world problems through tech.",
          style: TextStyle(fontSize: 18, color: Colors.white60),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => _launchURL("https://drive.google.com/file/d/1gpQseJwGA2JODxFnOFhdF410J-UusZ2H/view?usp=drivesdk"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          child: const Text("SEE MY RESUME", style: TextStyle(fontSize: 24, color: Colors.black)),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

// ---------------------- SKILLS SECTION ----------------------
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 600
            ? 3
            : 2;
        return Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Skills",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: const [
                  SkillCard(icon: Icons.code_rounded, label: "Flutter"),
                  SkillCard(icon: Icons.web, label: "Web Dev"),
                  SkillCard(icon: Icons.phone_android, label: "Mobile App"),
                  SkillCard(icon: Icons.cloud, label: "Firebase"),
                  SkillCard(icon: Icons.memory, label: "AI Tools"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SkillCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const SkillCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// ---------------------- PROJECTS SECTION ----------------------
class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;
        return Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Projects",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: const [
                  ProjectCard(
                    title: "Expense Tracker App",
                    description: "A Flutter app to track daily expenses and manage budgets and add incomes.",
                    link: "https://github.com/anishthakur408/anish-portfolio",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final String link;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const Spacer(),
            TextButton(
              onPressed: () => _launchURL(link),
              child: const Text("View on GitHub"),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

// ---------------------- FOOTER ----------------------
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          const Text(
            "Connect with me",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white),
                onPressed: () => _launchURL("https://github.com/anishthakur408"),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.linkedin, color: Colors.white),
                onPressed: () => _launchURL("https://www.linkedin.com/in/anish-thakur-408"),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.white),
                onPressed: () => _launchURL("https://x.com/anishthakur401"),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
                onPressed: () => _launchURL("https://www.instagram.com/anish_.thakur"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const ContactForm(),
          const SizedBox(height: 24),
          const Text(
            "© 2025 Anish Thakur. All rights reserved.",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

// ---------------------- CONTACT FORM ----------------------
class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for reaching out!')),
      );
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
            validator: (value) =>
            value == null || value.isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
            validator: (value) =>
            value == null || value.isEmpty ? 'Please enter a message' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Send', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
