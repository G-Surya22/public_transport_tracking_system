import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'services/halt_geofence_service.dart';
import 'firebase_options.dart';

const navyBlue = Color(0xFF092A4A);
const skyBlue = Color(0xFF4DB7E9);
const paleBlue = Color(0xFFEAF7FD);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PttsApp());
}

class PttsApp extends StatelessWidget {
  const PttsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PTTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: skyBlue),
        scaffoldBackgroundColor: const Color(0xFFF7FBFD),
        fontFamily: 'Arial',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8E9F1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: skyBlue, width: 2),
          ),
        ),
      ),
      home: const PttsHome(),
    );
  }
}

class PttsHome extends StatefulWidget {
  const PttsHome({super.key});

  @override
  State<PttsHome> createState() => _PttsHomeState();
}

class _PttsHomeState extends State<PttsHome> {
  bool _isLoading = true;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _loadingTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeOutCubic,
      child: _isLoading ? const LoadingScreen() : const SearchScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          backgroundColor: navyBlue,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CrewScreen()),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Login failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _returnToPassengerMode() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Crew Login',
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Switch to passenger mode',
                  style: TextStyle(
                    color: navyBlue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Transform.scale(
                  scale: 0.9,
                  child: Switch.adaptive(
                    value: true,
                    onChanged: (_) => _returnToPassengerMode(),
                    activeThumbColor: skyBlue,
                    activeTrackColor: paleBlue,
                    inactiveThumbColor: navyBlue,
                    inactiveTrackColor: const Color(0xFFD7E4EA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.directions_bus_rounded,
                      size: 52,
                      color: skyBlue,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Crew Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: navyBlue,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email ID',
                        prefixIcon: Icon(Icons.email_rounded, color: skyBlue),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_rounded, color: skyBlue),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : _login,
                        icon: const Icon(Icons.login_rounded),
                        label: Text(
                          _isSubmitting ? 'Logging in...' : 'Login',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: navyBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'New Crew? Register Here',
                          style: TextStyle(
                            color: navyBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await userCredential.user?.updateDisplayName(
        _nameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful'),
          backgroundColor: navyBlue,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        elevation: 0,
        title: const Text(
          'Create Crew Account',
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: navyBlue),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 52,
                      color: skyBlue,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create Crew Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: navyBlue,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_rounded, color: skyBlue),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_rounded, color: skyBlue),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_rounded, color: skyBlue),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : _register,
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(
                          _isSubmitting ? 'Registering...' : 'Register',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: navyBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
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

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('loading'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [navyBlue, Color(0xFF0B466D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.75, end: 1),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: const PttsLogo(light: true, showTagline: true),
          ),
        ),
      ),
    );
  }
}

class PttsLogo extends StatelessWidget {
  const PttsLogo({super.key, this.light = false, this.showTagline = false});

  final bool light;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : navyBlue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.directions_bus_rounded, size: 42, color: skyBlue),
        const SizedBox(height: 2),
        Text(
          'PTTS',
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            decoration: TextDecoration.underline,
            decorationColor: skyBlue,
            decorationThickness: 3,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 14),
          Text(
            'PUBLIC TRANSPORT, SIMPLIFIED',
            style: TextStyle(
              color: skyBlue,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}

class RouteMatch {
  final String routeId;
  final String routeName;
  final String source;
  final String destination;
  final List<RouteHalt> halts;

  const RouteMatch({
    required this.routeId,
    required this.routeName,
    required this.source,
    required this.destination,
    required this.halts,
  });

  List<String> get path => halts.map((halt) => halt.name).toList();
}

class RouteHalt extends HaltPoint {
  const RouteHalt({
    required super.name,
    required super.latitude,
    required super.longitude,
  });
}

List<String> endpointSuggestionsFromRoutes({
  required Map<String, dynamic> routesData,
  required bool source,
}) {
  final endpoints = <String>{};

  for (final routeData in routesData.values) {
    if (routeData is! Map) continue;
    final endpoint = (routeData[source ? 'source' : 'destination'] ?? '')
        .toString()
        .trim();
    if (endpoint.isNotEmpty) endpoints.add(endpoint);
  }

  return endpoints.toList()..sort();
}

int? _haltIndexFromKey(String key) {
  final match = RegExp(r'(\d+)').firstMatch(key);
  if (match == null) return null;
  return int.tryParse(match.group(1) ?? '');
}

List<RouteMatch> findMatchingRoutes({
  required String source,
  required String destination,
  required Map<String, dynamic> routesData,
}) {
  final normalizedSource = source.trim();
  final normalizedDestination = destination.trim();

  if (normalizedSource.isEmpty || normalizedDestination.isEmpty) {
    return const [];
  }

  final sourceKey = normalizedSource.toLowerCase();
  final destinationKey = normalizedDestination.toLowerCase();
  final matches = <RouteMatch>[];

  routesData.forEach((routeName, routeData) {
    if (routeData is! Map) return;

    final haltsMap = routeData['halts'];
    if (haltsMap is! Map) return;

    final orderedHaltEntries = haltsMap.entries.toList()
      ..sort((a, b) {
        final aIndex = _haltIndexFromKey(a.key.toString());
        final bIndex = _haltIndexFromKey(b.key.toString());

        if (aIndex == null && bIndex == null) {
          return a.key.toString().compareTo(b.key.toString());
        }
        if (aIndex == null) return 1;
        if (bIndex == null) return -1;
        return aIndex.compareTo(bIndex);
      });

    final halts = <RouteHalt>[];
    for (final entry in orderedHaltEntries) {
      final haltValue = entry.value;
      if (haltValue is! Map) continue;
      final haltName = (haltValue['name'] ?? '').toString().trim();
      if (haltName.isNotEmpty) {
        halts.add(
          RouteHalt(
            name: haltName,
            latitude: _asNullableDouble(haltValue['latitude']),
            longitude: _asNullableDouble(haltValue['longitude']),
          ),
        );
      }
    }

    if (halts.isEmpty) return;

    final routeSource = (routeData['source'] ?? '').toString().trim();
    final routeDestination = (routeData['destination'] ?? '').toString().trim();
    final normalizedHaltNames = halts.map((halt) => halt.name.toLowerCase()).toList();
    final sourceIndex = routeSource.isEmpty
        ? normalizedHaltNames.indexOf(sourceKey)
        : normalizedHaltNames.indexOf(routeSource.toLowerCase());
    final destinationIndex = routeDestination.isEmpty
        ? normalizedHaltNames.indexOf(destinationKey)
        : normalizedHaltNames.indexOf(routeDestination.toLowerCase());

    final sameRoute = sourceIndex != -1 && destinationIndex != -1;
    final requestedEndpointsMatch = routeSource.isEmpty ||
        (routeSource.toLowerCase() == sourceKey &&
            routeDestination.toLowerCase() == destinationKey);
    final validOrder = sameRoute && sourceIndex < destinationIndex && requestedEndpointsMatch;

    if (validOrder) {
      matches.add(
        RouteMatch(
          routeId: routeName,
          routeName: (routeData['name'] ?? routeName).toString(),
          source: routeSource.isEmpty ? normalizedSource : routeSource,
          destination: routeDestination.isEmpty ? normalizedDestination : routeDestination,
          halts: halts.sublist(sourceIndex, destinationIndex + 1),
        ),
      );
    }
  });

  return matches;
}

double? _asNullableDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

class SearchResultScreen extends StatelessWidget {
  final String source;
  final String destination;
  final List<RouteMatch> matches;

  const SearchResultScreen({
    super.key,
    required this.source,
    required this.destination,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        elevation: 0,
        title: const Text(
          'Search results',
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: navyBlue),
      ),
      body: matches.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 72,
                      color: skyBlue,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No routes found',
                      style: TextStyle(
                        color: navyBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No route contains $source before $destination.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF617887),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final match = matches[index];
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFDCEAF2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: paleBlue,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                match.routeName.toUpperCase(),
                                style: const TextStyle(
                                  color: navyBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.route_rounded,
                              color: skyBlue,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$source → $destination',
                          style: const TextStyle(
                            color: navyBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: match.path
                              .map(
                                (stop) => Chip(
                                  label: Text(stop),
                                  backgroundColor: paleBlue,
                                  labelStyle: const TextStyle(
                                    color: navyBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _isCrewMode = false;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _syncCrewMode();

    if (Firebase.apps.isNotEmpty) {
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (!mounted) return;
        setState(() => _isCrewMode = user != null);

        if (user != null && !_isCrewMode) {
          return;
        }

        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CrewScreen()),
          );
        }
      });
    }
  }

  void _syncCrewMode() {
    if (!mounted) return;

    final hasFirebaseApp = Firebase.apps.isNotEmpty;
    final isLoggedIn = hasFirebaseApp && FirebaseAuth.instance.currentUser != null;
    setState(() => _isCrewMode = isLoggedIn);
  }

  void _handleCrewModeToggle(bool value) {
    if (!value) {
      setState(() => _isCrewMode = false);
      return;
    }

    final hasFirebaseApp = Firebase.apps.isNotEmpty;
    final isLoggedIn = hasFirebaseApp && FirebaseAuth.instance.currentUser != null;

    if (isLoggedIn) {
      setState(() => _isCrewMode = true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CrewScreen()),
      );
      return;
    }

    setState(() => _isCrewMode = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) return;

    final source = _sourceController.text.trim();
    final destination = _destinationController.text.trim();

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching routes from $source to $destination',
        ),
        backgroundColor: navyBlue,
      ),
    );

    try {
      final snapshot = await FirebaseDatabase.instance.ref().child('routes').get();
      final rawData = snapshot.value;
      final routesData = rawData is Map ? Map<String, dynamic>.from(rawData) : const <String, dynamic>{};
      final matches = findMatchingRoutes(
        source: source,
        destination: destination,
        routesData: routesData,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultScreen(
            source: source,
            destination: destination,
            matches: matches,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultScreen(
            source: source,
            destination: destination,
            matches: const [],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('search'),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF7FBFD),
        toolbarHeight: 72,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bus_rounded, color: skyBlue, size: 28),
            SizedBox(width: 8),
            Text(
              'PTTS',
              style: TextStyle(
                color: navyBlue,
                fontWeight: FontWeight.w900,
                fontSize: 21,
                letterSpacing: 2.5,
                decoration: TextDecoration.underline,
                decorationColor: skyBlue,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isCrewMode ? 'Switch to passenger mode' : 'Switch to crew mode',
                  style: const TextStyle(
                    color: navyBlue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Transform.scale(
                  scale: 0.9,
                  child: Switch.adaptive(
                    value: _isCrewMode,
                    onChanged: _handleCrewModeToggle,
                    activeThumbColor: skyBlue,
                    activeTrackColor: paleBlue,
                    inactiveThumbColor: navyBlue,
                    inactiveTrackColor: const Color(0xFFD7E4EA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isCrewMode
          ? const CrewScreen()
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.route_rounded,
                            color: skyBlue,
                            size: 44,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Search public transport services',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: navyBlue,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Find the best way to get where you need to go.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF617887),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 34),
                          TextFormField(
                            controller: _sourceController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Source location',
                              prefixIcon: Icon(
                                Icons.trip_origin,
                                color: skyBlue,
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter your starting location'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _destinationController,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _search(),
                            decoration: const InputDecoration(
                              labelText: 'Destination location',
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: skyBlue,
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter your destination'
                                : null,
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: _search,
                              icon: const Icon(Icons.search),
                              label: const Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: navyBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: paleBlue,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: navyBlue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Enter two locations to discover available routes.',
                                    style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class CrewScreen extends StatefulWidget {
  const CrewScreen({super.key});

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  final _busNumberController = TextEditingController();
  List<RouteMatch> _routes = const [];
  List<String> _sourceSuggestions = const [];
  List<String> _destinationSuggestions = const [];
  RouteMatch? _selectedRoute;
  String? _activeJourneyId;
  Map<String, dynamic>? _activeJourney;
  Timer? _locationTimer;
  StreamSubscription<DatabaseEvent>? _journeySubscription;
  bool _isSearching = false;
  bool _isStarting = false;
  bool _isUpdatingLocation = false;
  int _currentHaltIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEndpointSuggestions();
  }

  Future<void> _loadEndpointSuggestions() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('routes').get();
      final rawData = snapshot.value;
      if (rawData is! Map) return;
      final routesData = Map<String, dynamic>.from(rawData);

      if (!mounted) return;
      setState(() {
        _sourceSuggestions = endpointSuggestionsFromRoutes(
          routesData: routesData,
          source: true,
        );
        _destinationSuggestions = endpointSuggestionsFromRoutes(
          routesData: routesData,
          source: false,
        );
      });
    } catch (_) {
      // Route search still reports a useful error if Firebase is unavailable.
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _stopLocationUpdates();
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _findRoutes() async {
    if (_sourceController.text.trim().isEmpty ||
        _destinationController.text.trim().isEmpty) {
      _formKey.currentState!.validate();
      return;
    }

    setState(() {
      _isSearching = true;
      _selectedRoute = null;
      _routes = const [];
    });

    try {
      final snapshot = await FirebaseDatabase.instance.ref('routes').get();
      final rawData = snapshot.value;
      final routesData = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : const <String, dynamic>{};
      final routes = findMatchingRoutes(
        source: _sourceController.text,
        destination: _destinationController.text,
        routesData: routesData,
      );

      if (!mounted) return;
      setState(() => _routes = routes);
      if (routes.isEmpty) {
        _showMessage('No route matches those endpoints.');
      }
    } catch (error) {
      if (mounted) _showMessage('Could not load routes from Firebase.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage('Turn on device location to start a journey.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('Location permission is required for live tracking.');
      return false;
    }
    return true;
  }

  Future<Position> _currentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _startJourney() async {
    if (_selectedRoute == null || !_formKey.currentState!.validate()) return;
    if (!await _ensureLocationPermission()) return;

    setState(() => _isStarting = true);
    try {
      final position = await _currentPosition();
      final now = DateTime.now().millisecondsSinceEpoch;
      final route = _selectedRoute!;
      final journeyRef = FirebaseDatabase.instance.ref('active_journeys').push();
      await journeyRef.set({
        'crew_id': FirebaseAuth.instance.currentUser?.uid,
        'bus_number': _busNumberController.text.trim(),
        'route_id': route.routeId,
        'source': route.source,
        'destination': route.destination,
        'started_at': now,
        'status': 'active',
        'current_location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': now,
        },
        'current_halt_index': 0,
      });

      if (!mounted) return;
      setState(() {
        _activeJourneyId = journeyRef.key;
        _activeJourney = {
          'bus_number': _busNumberController.text.trim(),
          'route_id': route.routeId,
          'source': route.source,
          'destination': route.destination,
          'started_at': now,
          'status': 'active',
          'current_location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': now,
          },
          'current_halt_index': 0,
        };
        _currentHaltIndex = 0;
      });
      _listenToJourney(journeyRef);
      _startLocationUpdates();
    } catch (error) {
      if (mounted) _showMessage('Could not start the journey. Please try again.');
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  void _listenToJourney(DatabaseReference journeyRef) {
    _journeySubscription?.cancel();
    _journeySubscription = journeyRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (!mounted || value is! Map) return;
      final journey = Map<String, dynamic>.from(value);
      final haltIndex = journey['current_halt_index'];
      setState(() {
        _activeJourney = journey;
        if (haltIndex is num) {
          _currentHaltIndex = haltIndex.toInt().clamp(0, _selectedRoute?.halts.length ?? 0);
        }
      });
    });
  }

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      final journeyId = _activeJourneyId;
      if (journeyId == null || _isUpdatingLocation) return;
      _isUpdatingLocation = true;
      try {
        final position = await _currentPosition();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final routeHalts = _selectedRoute?.halts ?? const <RouteHalt>[];
        final geofenceResult = const HaltGeofenceService().evaluate(
          currentLatitude: position.latitude,
          currentLongitude: position.longitude,
          halts: routeHalts,
          currentHaltIndex: _currentHaltIndex,
        );
        _currentHaltIndex = geofenceResult.currentHaltIndex;
        final journeyRef = FirebaseDatabase.instance.ref('active_journeys/$journeyId');
        await journeyRef.update({
          'current_location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': timestamp,
          },
          'current_halt_index': _currentHaltIndex,
        });
      } catch (_) {
        if (mounted) _showMessage('Unable to refresh GPS location.');
      } finally {
        _isUpdatingLocation = false;
      }
    });
  }

  Future<void> _stopLocationUpdates() async {
    _locationTimer?.cancel();
    _locationTimer = null;
    await _journeySubscription?.cancel();
    _journeySubscription = null;
  }

  Future<void> _stopJourney() async {
    final journeyId = _activeJourneyId;
    if (journeyId == null) return;

    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop journey?'),
        content: const Text(
          'This journey will be marked as aborted and live tracking will stop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Stop journey'),
          ),
        ],
      ),
    );

    if (shouldStop != true) return;

    try {
      await FirebaseDatabase.instance.ref('active_journeys/$journeyId').update({
        'status': 'aborted',
        'ended_at': DateTime.now().millisecondsSinceEpoch,
      });
      await _stopLocationUpdates();

      if (!mounted) return;
      setState(() {
        _activeJourneyId = null;
        _activeJourney = null;
        _selectedRoute = null;
        _routes = const [];
        _currentHaltIndex = 0;
        _busNumberController.clear();
      });
      _showMessage('Journey aborted.');
    } catch (_) {
      if (mounted) _showMessage('Could not stop the journey. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: navyBlue),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _journeySubscription?.cancel();
    _sourceController.dispose();
    _destinationController.dispose();
    _busNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crewName = FirebaseAuth.instance.currentUser?.displayName ?? 'Crew Member';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showMessage('Please logout to return to Passenger mode.');
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7FBFD),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            _activeJourney == null ? 'Crew Dashboard' : 'Live Journey',
            style: const TextStyle(color: navyBlue, fontWeight: FontWeight.w800),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: TextButton.styleFrom(foregroundColor: navyBlue),
            ),
          ],
        ),
        body: SafeArea(
          child: _activeJourney == null
              ? _buildSetup(crewName)
              : _buildLiveJourney(),
        ),
      ),
    );
  }

  Widget _buildSetup(String crewName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Welcome, $crewName', style: const TextStyle(color: navyBlue, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Initialize a trip for passengers to track.', style: TextStyle(color: Color(0xFF617887), fontSize: 15)),
                const SizedBox(height: 28),
                _buildLocationField(
                  controller: _sourceController,
                  label: 'Source',
                  icon: Icons.trip_origin,
                  suggestions: _sourceSuggestions,
                  emptyMessage: 'Enter the source',
                ),
                const SizedBox(height: 14),
                _buildLocationField(
                  controller: _destinationController,
                  label: 'Destination',
                  icon: Icons.location_on,
                  suggestions: _destinationSuggestions,
                  emptyMessage: 'Enter the destination',
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isSearching ? null : _findRoutes,
                  icon: const Icon(Icons.route_rounded),
                  label: Text(_isSearching ? 'Loading routes...' : 'Find routes'),
                  style: FilledButton.styleFrom(backgroundColor: navyBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                if (_routes.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const Text('Select the route', style: TextStyle(color: navyBlue, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ..._routes.map(_routeCard),
                  if (_selectedRoute != null) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _busNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Bus number',
                        prefixIcon: Icon(Icons.directions_bus, color: skyBlue),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter the bus number'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isStarting ? null : _startJourney,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(_isStarting ? 'Starting journey...' : 'Start journey'),
                    style: FilledButton.styleFrom(backgroundColor: skyBlue, foregroundColor: navyBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> suggestions,
    required String emptyMessage,
  }) {
    return RawAutocomplete<String>(
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<String>.empty();
        return suggestions.where(
          (suggestion) => suggestion.toLowerCase().contains(query),
        );
      },
      onSelected: (selection) {
        controller.value = TextEditingValue(
          text: selection,
          selection: TextSelection.collapsed(offset: selection.length),
        );
      },
      fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
        return TextFormField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          onChanged: (value) => controller.text = value,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: skyBlue),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? emptyMessage
              : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, color: skyBlue),
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _routeCard(RouteMatch route) {
    final isSelected = identical(_selectedRoute, route);
    return Card(
      elevation: 0,
      color: isSelected ? paleBlue : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isSelected ? skyBlue : const Color(0xFFDCEAF2), width: isSelected ? 2 : 1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedRoute = route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(route.routeId, style: const TextStyle(color: navyBlue, fontSize: 18, fontWeight: FontWeight.w800))),
              Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? skyBlue : const Color(0xFF8BA7B5)),
            ]),
            const SizedBox(height: 4),
            Text('${route.source} to ${route.destination}', style: const TextStyle(color: Color(0xFF617887))),
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: route.halts.map((halt) => Chip(label: Text(halt.name), backgroundColor: Colors.white, side: BorderSide.none)).toList()),
          ]),
        ),
      ),
    );
  }

  Widget _buildLiveJourney() {
    final journey = _activeJourney!;
    final route = _selectedRoute;
    final location = journey['current_location'] is Map ? Map<String, dynamic>.from(journey['current_location'] as Map) : const <String, dynamic>{};
    final currentHaltIndex = (journey['current_halt_index'] as num?)?.toInt() ?? 0;
    final halts = route?.halts ?? const <RouteHalt>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: navyBlue, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ACTIVE NOW', style: TextStyle(color: skyBlue, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text('${journey['source']} to ${journey['destination']}', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Bus ${journey['bus_number']}  |  Route ${journey['route_id']}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 18),
                Text('GPS ${_numberText(location['latitude'])}, ${_numberText(location['longitude'])}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                Text('Updated ${_timeText(location['timestamp'])}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 24),
            const Text('Journey progress', style: TextStyle(color: navyBlue, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...halts.asMap().entries.map((entry) {
              final index = entry.key;
              final halt = entry.value;
              final reached = index <= currentHaltIndex;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(reached ? Icons.check_circle : Icons.radio_button_unchecked, color: reached ? skyBlue : const Color(0xFF9AB1BC)),
                title: Text(halt.name, style: TextStyle(color: reached ? navyBlue : const Color(0xFF617887), fontWeight: FontWeight.w700)),
                subtitle: Text('${halt.latitude}, ${halt.longitude}'),
              );
            }),
            const SizedBox(height: 10),
            const Text('Location is refreshed every 12 seconds while this screen is open.', style: TextStyle(color: Color(0xFF617887), fontSize: 13)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _stopJourney,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop journey'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _numberText(dynamic value) => value is num ? value.toStringAsFixed(6) : '--';

  String _timeText(dynamic value) {
    if (value is! num) return 'waiting';
    final time = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
