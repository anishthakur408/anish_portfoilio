import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

// Configuration
const String kWeb3FormsAccessKey = '24ad25ec-5afd-438f-b197-3ac6e654ac1b';

// Helper to open external URLs in a single place
Future<bool> openExternalUrl(String url) async {
  try {
    final Uri uri = Uri.parse(url);
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

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
                children: [
                  const NavBar(),
                  // Wrap sections with FadeInSection and small staggered delays
                  FadeInSection(delay: const Duration(milliseconds: 100), child: HeroSection(mousePos: _mousePos)),
                  const FadeInSection(delay: Duration(milliseconds: 250), child: SkillsSection()),
                  const FadeInSection(delay: Duration(milliseconds: 400), child: ProjectSection()),
                  const FadeInSection(delay: Duration(milliseconds: 550), child: Footer()),
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

// Add: reusable fade-in + slide widget for smooth staggered appearance
class FadeInSection extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const FadeInSection({super.key, required this.child, this.delay = const Duration(milliseconds: 200)});

  @override
  State<FadeInSection> createState() => _FadeInSectionState();
}

class _FadeInSectionState extends State<FadeInSection> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _offset = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
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
class HeroSection extends StatefulWidget {
  final Offset mousePos;

  const HeroSection({super.key, required this.mousePos});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final List<String> _taglines = [
    "Flutter & Python Developer",
    "Cross-platform apps with clean code",
    "UI-focused, performance-minded",
    "Building products that solve problems",
  ];

  int _taglineIndex = 0;
  Timer? _taglineTimer;
  bool _isHoveringResume = false;

  @override
  void initState() {
    super.initState();
    _startTaglineLoop();
  }

  void _startTaglineLoop() {
    _taglineTimer?.cancel();
    _taglineTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _taglineIndex = (_taglineIndex + 1) % _taglines.length);
    });
  }

  @override
  void dispose() {
    _taglineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final rotateX = (widget.mousePos.dy - centerY) / centerY * 0.05;
    final rotateY = -(widget.mousePos.dx - centerX) / centerX * 0.05;

    // compute a light scale based on tilt for a subtle parallax effect
    final double tiltStrength = (rotateX.abs() + rotateY.abs()).clamp(0.0, 0.06);
    final double targetScale = 1.0 - tiltStrength;

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
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateX(rotateX)
                          ..rotateY(rotateY),
                        alignment: FractionalOffset.center,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 1.0, end: targetScale),
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                          child: Image.network("https://raw.githubusercontent.com/anishthakur408/images/main/profile.png"),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateX(rotateX)
                        ..rotateY(rotateY),
                      alignment: FractionalOffset.center,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 1.0, end: targetScale),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                        child: Image.network(
                          "https://raw.githubusercontent.com/anishthakur408/images/main/profile.png",
                          height: 250,
                        ),
                      ),
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
          "HI, I'm ANISH",
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),

        // Rotating tagline using AnimatedSwitcher for smooth transitions
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) {
            return FadeTransition(opacity: anim, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim), child: child));
          },
          child: Text(
            _taglines[_taglineIndex],
            key: ValueKey<int>(_taglineIndex),
            style: const TextStyle(fontSize: 28, color: Colors.white70),
          ),
        ),

        const SizedBox(height: 18),
        const Text(
          "I design and build fast, maintainable apps using Flutter and Python. "
          "I focus on intuitive UI, reliable architecture, and shipping real value.",
          style: TextStyle(fontSize: 18, color: Colors.white60),
        ),
        const SizedBox(height: 32),

        // Resume button with subtle hover scale
        MouseRegion(
          onEnter: (_) => setState(() => _isHoveringResume = true),
          onExit: (_) => setState(() => _isHoveringResume = false),
          child: AnimatedScale(
            scale: _isHoveringResume ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: ElevatedButton(
              onPressed: () => _launchURL("https://drive.google.com/file/d/1ujIjl8hdki3n9bkFg4OWvynHgIMLKeXt/view?usp=drive_link"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
                child: Text("SEE MY RESUME", style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
            ),
          ),
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
        final skills = [
          {'icon': Icons.code_rounded, 'label': "Flutter"},
          {'icon': Icons.web, 'label': "Web Dev"},
          {'icon': Icons.phone_android, 'label': "Mobile App"},
          {'icon': Icons.cloud, 'label': "Firebase"},
          {'icon': Icons.memory, 'label': "AI Tools"},
        ];
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
                children: List.generate(
                  skills.length,
                  (index) {
                    final s = skills[index];
                    // stagger the entrance by index
                    return SkillCard(
                      icon: s['icon'] as IconData,
                      label: s['label'] as String,
                      delay: Duration(milliseconds: 120 * index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Converted SkillCard to StatefulWidget to animate entrance + hover scale
class SkillCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Duration delay;

  const SkillCard({super.key, required this.icon, required this.label, this.delay = Duration.zero});

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _offset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            // increased hover scale for a more noticeable effect
            scale: _hovering ? 1.14 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                boxShadow: _hovering
                    ? [
                        // stronger glow + lift on hover
                        BoxShadow(color: Colors.white12, blurRadius: 20, spreadRadius: 1, offset: Offset(0, 8)),
                        BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4)),
                      ]
                    : [
                        // subtle default shadow
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                border: Border.all(color: _hovering ? Colors.white10 : Colors.transparent),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: _hovering ? 56 : 48, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(widget.label, style: TextStyle(color: Colors.white, fontSize: _hovering ? 20 : 18)),
                  ],
                ),
              ),
            ),
          ),
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
                    title: "Polorix Studio",
                    description: "A Digital agency thats buid stuff for new Brands in ofrdable price, built using HTML,CSS ,JS and My effort ",
                    link: "https://polorix-studio.web.app/",
                    icon: FontAwesomeIcons.p,
                  ),
                  ProjectCard(
                    title: "Snake Game",
                    description: "A popular snake game developed with Flutter. We can play on the web.",
                    link: "https://snakegame-79632.web.app/",
                    icon: FontAwesomeIcons.gamepad,
                  ),

                  ProjectCard(
                    title: "A Political Chess",
                    description: "A chess game just made for fun.",
                    link: "https://political-chess.web.app/?fbclid=PAZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQPNTY3MDY3MzQzMzUyNDI3AAGnSDYR8LAQ9Nv1tnxmJSHoR9oZE5-TbdUoisQFSRbjIBPZpQ0Bp2vdTR2Xye0_aem_P53xSEB38UOe4wKinJwMOQ",
                    icon: FontAwesomeIcons.chess,
                  ),
                  ProjectCard(
                    title: "Mindry",
                    description: "A mobile app for mood tracking and macking astehthic to do list ",
                    link: "https://play.google.com/store/apps/details?id=com.plorixstudio.mindflow&hl=en_IN",
                    icon: FontAwesomeIcons.m,
                  ),
                  ProjectCard(
                    title: "The Solar system",
                    description: "Our solar system using 3js and basic web dev usingwibe coding  ",
                    link: "https://solar-system-8ba70.web.app/",
                    icon: FontAwesomeIcons.earth,
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
  final IconData icon;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.link,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchURL(link),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FaIcon(
              icon,
              size: 150,
              color: Colors.white.withOpacity(0.08),
            ),
            Padding(
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
                ],
              ),
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
            "© 2026 Anish Thakur. All rights reserved.",
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

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    // Web3Forms access key (provided by you)
    const String web3formsAccessKey = '24ad25ec-5afd-438f-b197-3ac6e654ac1b';

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String message = _messageController.text.trim();

    final Uri uri = Uri.parse('https://api.web3forms.com/submit');

    final Map<String, dynamic> payload = {
      'access_key': web3formsAccessKey,
      'subject': 'Portfolio contact from $name',
      'name': name,
      'email': email,
      'message': message,
    };

    try {
      final http.Response response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent — thank you!')),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
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
            enabled: !_isSending,
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
            enabled: !_isSending,
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
            enabled: !_isSending,
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
          SizedBox(
            height: 48,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
              child: ElevatedButton(
                key: ValueKey<bool>(_isSending),
                onPressed: _isSending ? null : _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: _isSending
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send', style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
