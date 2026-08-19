import 'dart:async';

import 'package:flutter/material.dart';

const navyBlue = Color(0xFF092A4A);
const skyBlue = Color(0xFF4DB7E9);
const paleBlue = Color(0xFFEAF7FD);

void main() {
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

  void _search() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching routes from ${_sourceController.text.trim()} '
          'to ${_destinationController.text.trim()}',
        ),
        backgroundColor: navyBlue,
      ),
    );
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
                  activeColor: skyBlue,
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
