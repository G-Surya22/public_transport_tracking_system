import 'dart:async';
import 'services/sample.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final String routeName;
  final String source;
  final String destination;
  final List<String> path;

  const RouteMatch({
    required this.routeName,
    required this.source,
    required this.destination,
    required this.path,
  });
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

    final haltNames = <String>[];
    for (final entry in orderedHaltEntries) {
      final haltValue = entry.value;
      if (haltValue is! Map) continue;
      final haltName = (haltValue['name'] ?? '').toString().trim();
      if (haltName.isNotEmpty) {
        haltNames.add(haltName);
      }
    }

    if (haltNames.isEmpty) return;

    final normalizedHaltNames = haltNames.map((name) => name.toLowerCase()).toList();
    final sourceIndex = normalizedHaltNames.indexOf(sourceKey);
    final destinationIndex = normalizedHaltNames.indexOf(destinationKey);

    final sameRoute = sourceIndex != -1 && destinationIndex != -1;
    final validOrder = sameRoute && sourceIndex < destinationIndex;

    if (validOrder) {
      matches.add(
        RouteMatch(
          routeName: routeName,
          source: normalizedSource,
          destination: normalizedDestination,
          path: haltNames.sublist(sourceIndex, destinationIndex + 1),
        ),
      );
    }
  });

  return matches;
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

  @override
  void dispose() {
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
                  _isCrewMode ? 'Crew' : 'Passenger',
                  style: const TextStyle(
                    color: navyBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Switch.adaptive(
                  value: _isCrewMode,
                  onChanged: (value) => setState(() => _isCrewMode = value),
                  activeThumbColor: skyBlue,
                  activeTrackColor: paleBlue,
                  inactiveThumbColor: navyBlue,
                  inactiveTrackColor: const Color(0xFFD7E4EA),
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

class CrewScreen extends StatelessWidget {
  
  const CrewScreen({super.key});
  
  @override
  
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: paleBlue,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 62,
                color: navyBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Start journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navyBlue,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Begin a new public transport journey for passengers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF617887), fontSize: 15),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Journey setup is ready to begin.'),
                    backgroundColor: navyBlue,
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start journey'),
              style: FilledButton.styleFrom(
                backgroundColor: navyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
