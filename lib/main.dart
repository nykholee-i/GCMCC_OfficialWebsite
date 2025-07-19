import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Text size provider for managing text scaling
class TextSizeProvider extends ChangeNotifier {
  double _textScaleFactor = 1.0;

  double get textScaleFactor => _textScaleFactor;

  void increaseTextSize() {
    if (_textScaleFactor < 1.3) {
      _textScaleFactor += 0.1;
      notifyListeners();
    }
  }

  void resetTextSize() {
    _textScaleFactor = 1.0;
    notifyListeners();
  }

  void decreaseTextSize() {
    if (_textScaleFactor > 0.7) {
      _textScaleFactor -= 0.1;
      notifyListeners();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.loadAuthState();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => TextSizeProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentService()),
        ChangeNotifierProvider(create: (_) => FeedbackService()),
      ],
      child: GlobalCareApp(),
    ),
  );
}

class GlobalCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TextSizeProvider>(
      builder: (context, textSizeProvider, child) {
        return MaterialApp(
          title: 'Global Care Medical Center',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            fontFamily: GoogleFonts.poppins().fontFamily,
            scaffoldBackgroundColor: Color(0xFFF8FAFC),
            textTheme: TextTheme(
              headlineMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
              titleLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
              bodyMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
              labelLarge: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.black12,
              iconTheme: IconThemeData(color: Colors.indigo[900]),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: Colors.indigo.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size(100, 36),
                textStyle: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo,
                side: BorderSide(color: Colors.indigo, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black12,
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => MainPage(),
            '/appointment-receipt': (context) => AppointmentReceiptPage(),
          },
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textSizeProvider.textScaleFactor),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  Widget _buildNavItem(
    BuildContext context,
    String title,
    int index,
    bool isActive,
    bool isMobile,
  ) {
    return GestureDetector(
      onTap: () {
        DefaultTabController.of(context)?.animateTo(index);
        (context as Element).markNeedsBuild();
      },
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? Colors.indigo[700] : Colors.black,
        ),
      ),
    );
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => AuthDialog());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final textSizeProvider = Provider.of<TextSizeProvider>(context);

    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.indigo[700]!,
                        size: isMobile ? 28 : 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Global Care',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.indigo[900]!,
                          fontSize: isMobile ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  if (isMobile) ...[
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.account_circle,
                            color: Colors.indigo[700]!,
                            size: isMobile ? 24 : 28,
                          ),
                          onPressed: () {
                            if (authService.isLoggedIn) {
                              final tabController = DefaultTabController.of(
                                context,
                              );
                              if (tabController != null) {
                                tabController.animateTo(3); // Dashboard tab
                                (context as Element).markNeedsBuild();
                              }
                            } else {
                              _showAuthDialog(context);
                            }
                          },
                          tooltip: authService.isLoggedIn
                              ? 'Profile'
                              : 'Login/Sign Up',
                        ),
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.indigo[700]!),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildNavItem(
                              context,
                              'Home',
                              0,
                              DefaultTabController.of(context)?.index == 0,
                              isMobile,
                            ),
                            SizedBox(width: 24),
                            _buildNavItem(
                              context,
                              'Appointments',
                              1,
                              DefaultTabController.of(context)?.index == 1,
                              isMobile,
                            ),
                            SizedBox(width: 24),
                            _buildNavItem(
                              context,
                              'Feedback',
                              2,
                              DefaultTabController.of(context)?.index == 2,
                              isMobile,
                            ),
                            SizedBox(width: 24),
                            _buildNavItem(
                              context,
                              'Dashboard',
                              3,
                              DefaultTabController.of(context)?.index == 3,
                              isMobile,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (!authService.isLoggedIn) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.indigo[700]!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ElevatedButton(
                              onPressed: () => _showAuthDialog(context),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontSize: 14, // Reduced font size
                                  fontWeight: FontWeight.w500,
                                  color: Colors.indigo[700],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile
                                      ? 12
                                      : 16, // Reduced padding
                                  vertical: isMobile ? 6 : 8, // Reduced padding
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.indigo[700]!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ElevatedButton(
                              onPressed: () => _showAuthDialog(context),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontSize: 14, // Reduced font size
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[700],
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile
                                      ? 12
                                      : 16, // Reduced padding
                                  vertical: isMobile ? 6 : 8, // Reduced padding
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.indigo.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.indigo[700]!,
                                  size: isMobile ? 20 : 24,
                                ),
                                radius: isMobile ? 14 : 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${authService.username}',
                                style: GoogleFonts.poppins(
                                  color: Colors.indigo[700]!,
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: Colors.indigo[700]!,
                            ),
                            onPressed: () => authService.logout(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        drawer: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (!isMobile) return SizedBox.shrink();
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.indigo[700]!),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.white, size: 32),
                        SizedBox(width: 8),
                        Text(
                          'Global Care',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.indigo[700]!),
                    title: Text(
                      'Home',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: DefaultTabController.of(context)?.index == 0
                            ? Colors.indigo[700]
                            : Colors.black,
                        fontWeight: DefaultTabController.of(context)?.index == 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(0);
                      Navigator.pop(context);
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.event, color: Colors.indigo[700]!),
                    title: Text(
                      'Appointments',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: DefaultTabController.of(context)?.index == 1
                            ? Colors.indigo[700]
                            : Colors.black,
                        fontWeight: DefaultTabController.of(context)?.index == 1
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(1);
                      Navigator.pop(context);
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback, color: Colors.indigo[700]!),
                    title: Text(
                      'Feedback',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: DefaultTabController.of(context)?.index == 2
                            ? Colors.indigo[700]
                            : Colors.black,
                        fontWeight: DefaultTabController.of(context)?.index == 2
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(2);
                      Navigator.pop(context);
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.dashboard, color: Colors.indigo[700]!),
                    title: Text(
                      'Dashboard',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: DefaultTabController.of(context)?.index == 3
                            ? Colors.indigo[700]
                            : Colors.black,
                        fontWeight: DefaultTabController.of(context)?.index == 3
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(3);
                      Navigator.pop(context);
                      (context as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
            );
          },
        ),
        body: TabBarView(
          children: [
            HomePage(),
            AppointmentPage(),
            FeedbackPage(),
            DashboardPage(),
          ],
        ),
        floatingActionButton: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFAB(
                    heroTag: 'decreaseText',
                    onPressed: textSizeProvider.decreaseTextSize,
                    tooltip: 'Decrease text size',
                    icon: Icons.text_decrease,
                    isMobile: isMobile,
                  ),
                  _buildFAB(
                    heroTag: 'resetText',
                    onPressed: textSizeProvider.resetTextSize,
                    tooltip: 'Reset text size',
                    icon: Icons.text_fields,
                    isMobile: isMobile,
                  ),
                  _buildFAB(
                    heroTag: 'increaseText',
                    onPressed: textSizeProvider.increaseTextSize,
                    tooltip: 'Increase text size',
                    icon: Icons.text_increase,
                    isMobile: isMobile,
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildFAB({
    required String heroTag,
    required VoidCallback onPressed,
    required String tooltip,
    required IconData icon,
    required bool isMobile,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.indigo[700]!, size: isMobile ? 18 : 20),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      constraints: BoxConstraints(),
      splashColor: Colors.blue[600]!,
      highlightColor: Colors.blue[400]!,
    );
  }
}

class FeedbackPage extends StatefulWidget {
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final feedbackController = TextEditingController();
  double satisfactionRating = 3.0;
  bool _isSubmitting = false;

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    final feedback = {
      'rating': satisfactionRating,
      'comment': feedbackController.text,
      'date': DateFormat('MMM d, yyyy').format(DateTime.now()),
      'username':
          Provider.of<AuthService>(context, listen: false).username ?? 'Guest',
    };
    try {
      await Provider.of<FeedbackService>(
        context,
        listen: false,
      ).saveFeedback(feedback);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback submitted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        feedbackController.clear();
        satisfactionRating = 3.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save feedback: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return Container(
                    color: Color(0xFFF8FAFC),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 32 : 48,
                      horizontal: constraints.maxWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        // Header
                        Column(
                          children: [
                            Text(
                              'Your Feedback Matters',
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 26 : 30,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Help us improve by sharing your experience.',
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 15 : 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        // Feedback Form or Login Prompt
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 500),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 600),
                              padding: EdgeInsets.all(isMobile ? 20 : 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: !authService.isLoggedIn
                                  ? _buildLoginPrompt(isMobile)
                                  : _buildFeedbackForm(isMobile),
                            ),
                          ),
                        ),
                        // Added spacing before footer
                        SizedBox(height: isMobile ? 32 : 48),
                      ],
                    ),
                  );
                },
              ),
              // Footer now included in the scrollable content
              FooterSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.lock, size: isMobile ? 36 : 40, color: Colors.indigo[700]),
        SizedBox(height: 16),
        Text(
          'Sign in to share your feedback',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          'Please login or create an account to provide your valuable feedback.',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14 : 15,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            showDialog(context: context, builder: (context) => AuthDialog());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 12 : 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            'Login / Sign Up',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 15 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackForm(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Your Experience',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Satisfaction Level: ${satisfactionRating.toStringAsFixed(1)}',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < satisfactionRating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: isMobile ? 24 : 28,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8),
          Slider(
            value: satisfactionRating,
            min: 1,
            max: 5,
            divisions: 4,
            label: satisfactionRating.toStringAsFixed(1),
            onChanged: (value) => setState(() => satisfactionRating = value),
            activeColor: Colors.indigo[700],
            inactiveColor: Colors.indigo[100],
          ),
          SizedBox(height: 24),
          Text(
            'Your Feedback',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 12),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: feedbackController,
              decoration: InputDecoration(
                labelText: 'Share your thoughts',
                hintText: 'Tell us about your experience or suggestions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.indigo.withOpacity(0.05),
                labelStyle: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : 15,
                ),
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: isMobile ? 14 : 15,
                ),
              ),
              minLines: 4,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide your feedback.';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 24),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 14 : 16,
                  horizontal: isMobile ? 24 : 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.indigo.withOpacity(0.3),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: isMobile ? 20 : 24,
                      width: isMobile ? 20 : 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit Feedback',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          MissionVisionSection(),
          ServicesSection(),
          ContactSection(),
          FooterSection(),
        ],
      ),
    );
  }
}

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [AppointmentSection(), FooterSection()]),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [DashboardSection(), FooterSection()]),
    );
  }
}

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _username;
  String? _email;
  static const String _usersKey = 'users';

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;

  Future<void> loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(usersJson));
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers();
    final user = users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      _isLoggedIn = true;
      _username = user['username'];
      _email = email;
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', user['username']);
      await prefs.setString('email', email);
      notifyListeners();
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> signup(String username, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers();

    if (users.any((u) => u['username'] == username)) {
      throw Exception('Username already exists');
    }

    users.add({'username': username, 'email': email, 'password': password});

    await _saveUsers(users);
    _isLoggedIn = true;
    _username = username;
    _email = email;
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _username = null;
    _email = null;
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
    await prefs.remove('email');
    notifyListeners();
  }
}

class AppointmentService extends ChangeNotifier {
  static const String _appointmentsKey = 'appointments';

  Future<List<Map<String, dynamic>>> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = prefs.getString(_appointmentsKey);
    if (appointmentsJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(appointmentsJson));
  }

  Future<void> saveAppointment(Map<String, dynamic> appointment) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = await loadAppointments();
    appointments.add(appointment);
    await prefs.setString(_appointmentsKey, jsonEncode(appointments));
    notifyListeners();
  }

  Future<void> clearAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appointmentsKey);
    notifyListeners();
  }
}

class FeedbackService extends ChangeNotifier {
  static const String _feedbackKey = 'feedback';

  Future<List<Map<String, dynamic>>> loadFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final feedbackJson = prefs.getString(_feedbackKey);
    if (feedbackJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(feedbackJson));
  }

  Future<void> saveFeedback(Map<String, dynamic> feedback) async {
    final prefs = await SharedPreferences.getInstance();
    final feedbackList = await loadFeedback();
    feedbackList.add(feedback);
    await prefs.setString(_feedbackKey, jsonEncode(feedbackList));
    notifyListeners();
  }

  Future<void> clearFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedbackKey);
    notifyListeners();
  }
}

class AuthDialog extends StatefulWidget {
  const AuthDialog({Key? key}) : super(key: key);

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupUsernameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupUsernameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        await Provider.of<AuthService>(
          context,
          listen: false,
        ).login(_loginEmailController.text, _loginPasswordController.text);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitSignup() async {
    if (_signupFormKey.currentState!.validate()) {
      if (_signupPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        await Provider.of<AuthService>(context, listen: false).signup(
          _signupUsernameController.text,
          _signupEmailController.text,
          _signupPasswordController.text,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? 400 : 500,
          minWidth: isMobile ? 300 : 400,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: theme.primaryColor,
                      size: isMobile ? 24 : 32,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Global Care',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListenableBuilder(
                    listenable: _tabController.animation!,
                    builder: (context, _) {
                      final index = _tabController.animation!.value.round();
                      return TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: theme.primaryColor,
                        indicator: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: index == 0
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                )
                              : BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, size: isMobile ? 18 : 20),
                                SizedBox(width: 4),
                                Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add,
                                  size: isMobile ? 18 : 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Sign Up',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: isMobile ? 400 : 450,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Login Tab
                      Form(
                        key: _loginFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _loginEmailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.indigo.withOpacity(0.05),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _loginPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.indigo.withOpacity(0.05),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Forgot password
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    color: theme.primaryColor,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _tabController.animateTo(1),
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.poppins(
                                      color: theme.primaryColor,
                                      fontSize: isMobile ? 12 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Sign Up Tab
                      Form(
                        key: _signupFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _signupUsernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.indigo.withOpacity(0.05),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _signupEmailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.indigo.withOpacity(0.05),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _signupPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                helperText: 'At least 6 characters',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.indigo.withOpacity(0.05),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.indigo.withOpacity(0.05),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _tabController.animateTo(0),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      color: theme.primaryColor,
                                      fontSize: isMobile ? 12 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final screenHeight = MediaQuery.of(context).size.height;

        return Stack(
          children: [
            Container(
              height: screenHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/2094Calamba_City_Canlubang_Roads_Landmarks_Barangays_31.jpg/1200px-2094Calamba_City_Canlubang_Roads_Landmarks_Barangays_31.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: screenHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xAA1E40AF), Color(0x803B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Container(
              height: screenHeight,
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05,
                vertical: isMobile ? 16 : 24,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      'Welcome to Global Care Medical Center',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 24 : 36,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  AnimatedSlide(
                    offset: Offset(0, 0),
                    duration: Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    child: Text(
                      'Providing compassionate care and cutting-edge medical services to our community. At Global, We Care!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: isMobile ? 14 : 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo[700],
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 28,
                            vertical: isMobile ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        onPressed: () {
                          if (authService.isLoggedIn) {
                            try {
                              final tabController = DefaultTabController.of(
                                context,
                              );
                              if (tabController != null) {
                                tabController.animateTo(1);
                                (context as Element).markNeedsBuild();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Navigation error. Please try again.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Navigation error: $e')),
                              );
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AuthDialog(),
                            );
                          }
                        },
                        child: Text(
                          'Book Appointment',
                          style: GoogleFonts.poppins(
                            color: Colors.indigo[700],
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 28,
                            vertical: isMobile ? 12 : 16,
                          ),
                          side: BorderSide(color: Colors.white, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Learn More clicked!')),
                          );
                        },
                        child: Text(
                          'Learn More',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 24),
                  HeroStats(isMobile: isMobile),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class HeroStats extends StatelessWidget {
  final bool isMobile;
  HeroStats({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 1500),
      child: Container(
        margin: EdgeInsets.only(top: isMobile ? 12 : 24),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: isMobile ? 20 : 40,
          runSpacing: 12,
          children: [
            StatItem(
              icon: Icons.medical_services,
              number: '210+',
              label: 'Expert Doctors',
              isMobile: isMobile,
            ),
            StatItem(
              icon: Icons.local_hospital,
              number: '150+',
              label: 'Departments',
              isMobile: isMobile,
            ),
            StatItem(
              icon: Icons.people,
              number: '10K+',
              label: 'Happy Patients',
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final bool isMobile;
  const StatItem({
    required this.icon,
    required this.number,
    required this.label,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: isMobile ? 24 : 32),
        SizedBox(height: 4),
        Text(
          number,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class MissionVisionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Container(
          color: Color(0xFFF8FAFC),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 24 : 40,
            horizontal: constraints.maxWidth * 0.05,
          ),
          child: Column(
            children: [
              SectionHeader(title: 'Our Mission & Vision'),
              SizedBox(height: isMobile ? 12 : 24),
              isMobile
                  ? Column(
                      children: [
                        MissionVisionCard(
                          title: 'Our Mission',
                          icon: Icons.track_changes,
                          content:
                              "To improve patient's lives by providing safe, effective and suitable medical services performed only by high capable staffs and medical professionals while establishing an environment where customers, employees and stakeholders are valued and involved in continuously improving the quality of our services towards a healthier community.",
                          isMobile: isMobile,
                        ),
                        SizedBox(height: 16),
                        MissionVisionCard(
                          title: 'Our Vision',
                          icon: Icons.remove_red_eye,
                          content:
                              "Global Care Medical Center of Canlubang is the optimal healthcare provider in the Community that delivers excellent medical service in the most professional and compassionate way at the most reasonable cost.",
                          isMobile: isMobile,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MissionVisionCard(
                            title: 'Our Mission',
                            icon: Icons.track_changes,
                            content:
                                "To improve patient's lives by providing safe, effective and suitable medical services performed only by high capable staffs and medical professionals while establishing an environment where customers, employees and stakeholders are valued and involved in continuously improving the quality of our services towards a healthier community.",
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: MissionVisionCard(
                            title: 'Our Vision',
                            icon: Icons.remove_red_eye,
                            content:
                                "Global Care Medical Center of Canlubang is the optimal healthcare provider in the Community that delivers excellent medical service in the most professional and compassionate way at the most reasonable cost.",
                            isMobile: isMobile,
                          ),
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

class MissionVisionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final bool isMobile;

  MissionVisionCard({
    required this.title,
    required this.icon,
    required this.content,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 800),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: Icon(icon, color: Colors.indigo[700]),
                radius: isMobile ? 24 : 28,
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServicesSection extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.local_hospital,
      'title': 'Emergency Care',
      'desc':
          'Available 24/7 for all emergency medical needs with state-of-the-art facilities.',
    },
    {
      'icon': Icons.favorite,
      'title': 'Primary Care',
      'desc':
          'Comprehensive primary healthcare services for patients of all ages.',
    },
    {
      'icon': Icons.healing,
      'title': 'Specialized Treatment',
      'desc':
          'Expert specialists providing advanced care across multiple medical disciplines.',
    },
    {
      'icon': Icons.science,
      'title': 'Laboratory Services',
      'desc': 'Advanced diagnostic testing with quick and accurate results.',
    },
    {
      'icon': Icons.medication,
      'title': 'Pharmacy',
      'desc':
          'On-site pharmacy providing prescription medications and health products.',
    },
    {
      'icon': Icons.fitness_center,
      'title': 'Rehabilitation',
      'desc':
          'Comprehensive rehabilitation services to help patients recover and regain independence.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 900
            ? 2
            : 3;
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 24 : 40,
            horizontal: constraints.maxWidth * 0.05,
          ),
          child: Column(
            children: [
              SectionHeader(
                title: 'Our Services',
                subtitle:
                    'Comprehensive medical services to meet all your healthcare needs.',
              ),
              SizedBox(height: isMobile ? 12 : 24),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isMobile ? 16 : 24,
                mainAxisSpacing: isMobile ? 16 : 24,
                childAspectRatio: isMobile ? 1.3 : 1.1,
                children: services
                    .asMap()
                    .entries
                    .map(
                      (entry) => AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 500 + entry.key * 200),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.indigo.withOpacity(
                                    0.1,
                                  ),
                                  radius: isMobile ? 28 : 36,
                                  child: Icon(
                                    entry.value['icon'],
                                    color: Colors.indigo[700],
                                    size: isMobile ? 24 : 28,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  entry.value['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  entry.value['desc'],
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${entry.value['title']} Learn More clicked!',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_right_alt,
                                    color: Colors.indigo[700],
                                    size: isMobile ? 20 : 24,
                                  ),
                                  label: Text('Learn More'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppointmentSection extends StatefulWidget {
  const AppointmentSection({Key? key}) : super(key: key);

  @override
  State<AppointmentSection> createState() => _AppointmentSectionState();
}

class _AppointmentSectionState extends State<AppointmentSection> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Container(
              color: Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24 : 40,
                horizontal: constraints.maxWidth * 0.05,
              ),
              child: Column(
                children: [
                  SectionHeader(
                    title: 'Book an Appointment',
                    subtitle:
                        'Schedule your visit with our expert medical professionals.',
                  ),
                  SizedBox(height: isMobile ? 12 : 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TabButton(
                                  label: 'New Appointment',
                                  active: tabIndex == 0,
                                  onTap: () => setState(() => tabIndex = 0),
                                ),
                              ),
                              Expanded(
                                child: TabButton(
                                  label: 'History',
                                  active: tabIndex == 1,
                                  onTap: () => setState(() => tabIndex = 1),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 16 : 24),
                          if (!authService.isLoggedIn && tabIndex == 0)
                            Column(
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: isMobile ? 32 : 40,
                                  color: Colors.indigo[700],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Please login or sign up to book an appointment',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AuthDialog(),
                                    );
                                  },
                                  child: Text('Login / Sign Up'),
                                ),
                              ],
                            )
                          else
                            tabIndex == 0
                                ? AppointmentForm(isMobile: isMobile)
                                : AppointmentHistory(isMobile: isMobile),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  TabButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: active ? Colors.indigo[700] : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: active ? Colors.white : Color(0xFF6B7280),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: active ? Colors.white : Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AppointmentForm extends StatefulWidget {
  final bool isMobile;
  AppointmentForm({required this.isMobile});

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  DateTime? selectedDate;
  String? selectedTime;
  String? department;
  String? doctor;
  String? appointmentType;
  final reasonController = TextEditingController();

  final departments = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Dermatology',
  ];

  final doctorsByDepartment = {
    'Cardiology': [
      'Dra. Joan Dympha P. Reano',
      'Dr. Rocky Danillo S. Willis',
      'Dr. James Patrick Diaz',
    ],
    'Neurology': [
      'Dra. Cynthia B. Anacay',
      'Dr. Mark Kryster I. Panaligan',
      'Dr. Roman Santos',
    ],
    'Orthopedics': [
      'Dra. Arabella P. Quing',
      'Dra. Maria Thea M. Nido',
      'Dr. Edgardo J. Cuadra',
    ],
    'Pediatrics': [
      'Dr. Anner A. Marquez',
      'Dr. Ching C. Casao',
      'Dr. Jaypee V. Perez',
    ],
    'Dermatology': [
      'Dra. Ashley R. Medina',
      'Dra. Maria Reginas B. Evia',
      'Dr. Gay C. San Antonio',
    ],
  };

  final appointmentTypes = [
    'New Patient',
    'Follow-up',
    'Consultation',
    'Procedure',
  ];

  List<String> get doctors =>
      department != null && doctorsByDepartment.containsKey(department)
      ? doctorsByDepartment[department]!
      : [];

  List<String> get timeSlots {
    final slots = <String>[];
    for (int h = 9; h <= 17; h++) {
      slots.add('${_formatHour(h)}:00 ${_ampm(h)}');
      if (h < 17) slots.add('${_formatHour(h)}:30 ${_ampm(h)}');
    }
    return slots;
  }

  static String _formatHour(int h) => (h % 12 == 0 ? 12 : h % 12).toString();
  static String _ampm(int h) => h < 12 ? 'AM' : 'PM';

  void _submit() {
    String? errorMessage;
    if (selectedDate == null) {
      errorMessage = 'Please select a date.';
    } else if (selectedTime == null) {
      errorMessage = 'Please select a time slot.';
    } else if (department == null) {
      errorMessage = 'Please select a department.';
    } else if (doctor == null) {
      errorMessage = 'Please select a doctor.';
    } else if (appointmentType == null) {
      errorMessage = 'Please select an appointment type.';
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    final appointment = {
      'avatar':
          'https://api.dicebear.com/7.x/avataaars/svg?seed=${doctor!.replaceAll(' ', '')}',
      'doctor': doctor,
      'department': department,
      'type': appointmentType,
      'date':
          DateFormat('MMM d, yyyy').format(selectedDate!) + ' at $selectedTime',
      'status': 'Upcoming',
      'reason': reasonController.text,
    };

    Provider.of<AppointmentService>(context, listen: false)
        .saveAppointment(appointment)
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Appointment scheduled successfully!')),
            );
            Navigator.pushNamed(
              context,
              '/appointment-receipt',
              arguments: {
                'date': selectedDate,
                'time': selectedTime,
                'doctor': doctor,
                'department': department,
                'appointmentType': appointmentType,
                'reason': reasonController.text,
                'username':
                    Provider.of<AuthService>(context, listen: false).username ??
                    'Guest',
              },
            );
            setState(() {
              selectedDate = null;
              selectedTime = null;
              department = null;
              doctor = null;
              appointmentType = null;
              reasonController.clear();
            });
          }
        })
        .catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save appointment: $e')),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buildContext) => widget.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date & Time',
                  style: GoogleFonts.poppins(
                    fontSize: widget.isMobile ? 16 : 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  onDateChanged: (date) => setState(() {
                    selectedDate = date;
                    selectedTime = null;
                  }),
                ),
                SizedBox(height: 12),
                Text(
                  'Available Time Slots',
                  style: GoogleFonts.poppins(
                    fontSize: widget.isMobile ? 16 : 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timeSlots
                      .map(
                        (slot) => ChoiceChip(
                          label: Text(slot),
                          selected: selectedTime == slot,
                          onSelected: (_) =>
                              setState(() => selectedTime = slot),
                          selectedColor: Colors.indigo[700],
                          labelStyle: GoogleFonts.poppins(
                            color: selectedTime == slot
                                ? Colors.white
                                : Colors.indigo[700],
                            fontSize: widget.isMobile ? 14 : 16,
                          ),
                          backgroundColor: Colors.indigo.withOpacity(0.05),
                          side: BorderSide(color: Colors.indigo[700]!),
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.isMobile ? 12 : 16,
                            vertical: widget.isMobile ? 6 : 8,
                          ),
                          elevation: selectedTime == slot ? 2 : 0,
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 16),
                Text(
                  'Appointment Details',
                  style: GoogleFonts.poppins(
                    fontSize: widget.isMobile ? 16 : 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.indigo.withOpacity(0.05),
                  ),
                  value: department,
                  items: [
                    DropdownMenuItem(
                      child: Text('Select Department'),
                      value: null,
                    ),
                    ...departments.map(
                      (d) => DropdownMenuItem(child: Text(d), value: d),
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    department = v;
                    doctor = null;
                  }),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Doctor',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.indigo.withOpacity(0.05),
                  ),
                  value: doctor,
                  items: [
                    DropdownMenuItem(child: Text('Select Doctor'), value: null),
                    ...doctors.map(
                      (d) => DropdownMenuItem(child: Text(d), value: d),
                    ),
                  ],
                  onChanged: (v) => setState(() => doctor = v),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Appointment Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.indigo.withOpacity(0.05),
                  ),
                  value: appointmentType,
                  items: [
                    DropdownMenuItem(child: Text('Select Type'), value: null),
                    ...appointmentTypes.map(
                      (t) => DropdownMenuItem(child: Text(t), value: t),
                    ),
                  ],
                  onChanged: (v) => setState(() => appointmentType = v),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason for Visit',
                    hintText:
                        'Please describe your symptoms or reason for visit.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.indigo.withOpacity(0.05),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Schedule Appointment'),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date & Time',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      CalendarDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        onDateChanged: (date) => setState(() {
                          selectedDate = date;
                          selectedTime = null;
                        }),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Available Time Slots',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: timeSlots
                            .map(
                              (slot) => ChoiceChip(
                                label: Text(slot),
                                selected: selectedTime == slot,
                                onSelected: (_) =>
                                    setState(() => selectedTime = slot),
                                selectedColor: Colors.indigo[700],
                                labelStyle: GoogleFonts.poppins(
                                  color: selectedTime == slot
                                      ? Colors.white
                                      : Colors.indigo[700],
                                ),
                                backgroundColor: Colors.indigo.withOpacity(
                                  0.05,
                                ),
                                side: BorderSide(color: Colors.indigo[700]!),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: selectedTime == slot ? 2 : 0,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.indigo.withOpacity(0.05),
                        ),
                        value: department,
                        items: [
                          DropdownMenuItem(
                            child: Text('Select Department'),
                            value: null,
                          ),
                          ...departments.map(
                            (d) => DropdownMenuItem(child: Text(d), value: d),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          department = v;
                          doctor = null;
                        }),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Doctor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.indigo.withOpacity(0.05),
                        ),
                        value: doctor,
                        items: [
                          DropdownMenuItem(
                            child: Text('Select Doctor'),
                            value: null,
                          ),
                          ...doctors.map(
                            (d) => DropdownMenuItem(child: Text(d), value: d),
                          ),
                        ],
                        onChanged: (v) => setState(() => doctor = v),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Appointment Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.indigo.withOpacity(0.05),
                        ),
                        value: appointmentType,
                        items: [
                          DropdownMenuItem(
                            child: Text('Select Type'),
                            value: null,
                          ),
                          ...appointmentTypes.map(
                            (t) => DropdownMenuItem(child: Text(t), value: t),
                          ),
                        ],
                        onChanged: (v) => setState(() => appointmentType = v),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: reasonController,
                        decoration: InputDecoration(
                          labelText: 'Reason for Visit',
                          hintText:
                              'Please describe your symptoms or reason for visit.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.indigo.withOpacity(0.05),
                        ),
                        minLines: 3,
                        maxLines: 5,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text('Schedule Appointment'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class AppointmentReceiptPage extends StatelessWidget {
  Future<void> _downloadReceipt(
    BuildContext context, {
    required String id,
    required String? username,
    required DateTime? date,
    required String? time,
    required String? doctor,
    required String? department,
    required String? appointmentType,
    required String? reason,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Global Care Medical Center',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Appointment Receipt',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Your appointment has been successfully scheduled.',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.indigo200),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Appointment Details',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _pdfSummaryRow('Appointment ID:', '#$id', font),
                      _pdfSummaryRow('Patient:', username ?? 'Guest', font),
                      _pdfSummaryRow(
                        'Date:',
                        date != null
                            ? DateFormat('MMMM d, yyyy').format(date)
                            : 'N/A',
                        font,
                      ),
                      _pdfSummaryRow('Time:', time ?? 'N/A', font),
                      _pdfSummaryRow('Doctor:', doctor ?? 'N/A', font),
                      _pdfSummaryRow('Department:', department ?? 'N/A', font),
                      _pdfSummaryRow('Type:', appointmentType ?? 'N/A', font),
                      _pdfSummaryRow(
                        'Reason:',
                        reason?.isEmpty ?? true ? 'Not specified' : reason!,
                        font,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.only(left: 12),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.indigo700, width: 3),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Confirmation',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'A confirmation email will be sent to your registered email address.',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Please arrive 15 minutes early and bring a valid ID.',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Location: J. Yulo Avenue, Brgy. Canlubang',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'appointment_receipt_$id.pdf',
    );
  }

  pw.Widget _pdfSummaryRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final DateTime? date = args?['date'] as DateTime?;
    final String? time = args?['time'] as String?;
    final String? doctor = args?['doctor'] as String?;
    final String? department = args?['department'] as String?;
    final String? appointmentType = args?['appointmentType'] as String?;
    final String? reason = args?['reason'] as String?;
    final String? username = args?['username'] as String?;

    final id = date != null
        ? (100000 + (date.millisecondsSinceEpoch % 900000)).toString()
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.indigo[700]),
          onPressed: () {
            Navigator.pop(context);
            final tabController = DefaultTabController.of(context);
            if (tabController != null) {
              tabController.animateTo(1);
            }
          },
        ),
        title: Text(
          'Appointment Receipt',
          style: GoogleFonts.poppins(
            color: Colors.indigo[900],
            fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Container(
              color: Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24 : 40,
                horizontal: constraints.maxWidth * 0.05,
              ),
              child: Column(
                children: [
                  SectionHeader(
                    title: 'Appointment Receipt',
                    subtitle:
                        'Your appointment has been successfully scheduled.',
                  ),
                  SizedBox(height: isMobile ? 12 : 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: isMobile ? 24 : 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Appointment Confirmed',
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.indigo.withOpacity(0.2),
                              ),
                            ),
                            padding: EdgeInsets.all(12),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appointment Details',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _summaryRow(
                                  'Appointment ID:',
                                  '#$id',
                                  isMobile,
                                ),
                                _summaryRow(
                                  'Patient:',
                                  username ?? 'Guest',
                                  isMobile,
                                ),
                                _summaryRow(
                                  'Date:',
                                  date != null
                                      ? DateFormat('MMMM d, yyyy').format(date)
                                      : 'N/A',
                                  isMobile,
                                ),
                                _summaryRow('Time:', time ?? 'N/A', isMobile),
                                _summaryRow(
                                  'Doctor:',
                                  doctor ?? 'N/A',
                                  isMobile,
                                ),
                                _summaryRow(
                                  'Department:',
                                  department ?? 'N/A',
                                  isMobile,
                                ),
                                _summaryRow(
                                  'Type:',
                                  appointmentType ?? 'N/A',
                                  isMobile,
                                ),
                                _summaryRow(
                                  'Reason:',
                                  reason?.isEmpty ?? true
                                      ? 'Not specified'
                                      : reason!,
                                  isMobile,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.indigo[700]!,
                                  width: 3,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confirmation',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'A confirmation email will be sent to your registered email address.',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please arrive 15 minutes early and bring a valid ID.',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Location: J. Yulo Avenue, Brgy. Canlubang',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  final tabController = DefaultTabController.of(
                                    context,
                                  );
                                  if (tabController != null) {
                                    tabController.animateTo(1);
                                  }
                                },
                                child: Text('Back to Appointments'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _downloadReceipt(
                                  context,
                                  id: id,
                                  username: username,
                                  date: date,
                                  time: time,
                                  doctor: doctor,
                                  department: department,
                                  appointmentType: appointmentType,
                                  reason: reason,
                                ),
                                icon: Icon(
                                  Icons.download,
                                  size: isMobile ? 16 : 18,
                                ),
                                label: Text('Download Receipt'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo[700],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 12 : 16,
                                    vertical: isMobile ? 8 : 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 120 : 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentHistory extends StatelessWidget {
  final bool isMobile;

  AppointmentHistory({required this.isMobile}); // Fixed constructor

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Provider.of<AppointmentService>(context).loadAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading appointments'));
        }
        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return Center(
            child: Text(
              'No appointments found.',
              style: GoogleFonts.poppins(fontSize: isMobile ? 16 : 18),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(appointment['avatar']),
                      radius: isMobile ? 24 : 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['doctor'] ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            appointment['department'] ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            appointment['date'] ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            appointment['type'] ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Status: ${appointment['status'] ?? 'N/A'}',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 16,
                              color: appointment['status'] == 'Upcoming'
                                  ? Colors.green
                                  : Colors.grey[600],
                            ),
                          ),
                          if (appointment['reason']?.isNotEmpty ?? false)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'Reason: ${appointment['reason']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 14 : 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ContactSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Container(
          color: Color(0xFFF8FAFC),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 24 : 40,
            horizontal: constraints.maxWidth * 0.05,
          ),
          child: Column(
            children: [
              SectionHeader(
                title: 'Contact Us',
                subtitle: 'Get in touch with our team for any inquiries.',
              ),
              SizedBox(height: isMobile ? 12 : 24),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContactItem(
                              icon: Icons.location_on,
                              title: 'Address',
                              content: 'J. Yulo Avenue, Brgy. Canlubang',
                              isMobile: isMobile,
                            ),
                            SizedBox(height: 16),
                            ContactItem(
                              icon: Icons.phone,
                              title: 'Phone',
                              content: '(049) 520-5626',
                              isMobile: isMobile,
                              onTap: () async {
                                final url = Uri.parse('tel:(049) 520-5626');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Cannot launch phone'),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 16),
                            ContactItem(
                              icon: Icons.email,
                              title: 'Email',
                              content: 'gcmccanlubang@gmail.com',
                              isMobile: isMobile,
                              onTap: () async {
                                final url = Uri.parse(
                                  'mailto:gcmccanlubang@gmail.com',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Cannot launch email'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ContactItem(
                                icon: Icons.location_on,
                                title: 'Address',
                                content: 'J. Yulo Avenue, Brgy. Canlubang',
                                isMobile: isMobile,
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: ContactItem(
                                icon: Icons.phone,
                                title: 'Phone',
                                content: '(049) 520-5626',
                                isMobile: isMobile,
                                onTap: () async {
                                  final url = Uri.parse('tel:(049) 520-5626');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot launch phone'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: ContactItem(
                                icon: Icons.email,
                                title: 'Email',
                                content: 'gcmccanlubang@gmail.com',
                                isMobile: isMobile,
                                onTap: () async {
                                  final url = Uri.parse(
                                    'mailto:gcmccanlubang@gmail.com',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot launch email'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isMobile;
  final VoidCallback? onTap;

  ContactItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.isMobile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigo.withOpacity(0.1),
            child: Icon(icon, color: Colors.indigo[700]),
            radius: isMobile ? 20 : 24,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Container(
          color: Colors.indigo[900],
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 24 : 40,
            horizontal: constraints.maxWidth * 0.05,
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: isMobile ? 24 : 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Global Care',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Providing compassionate care and cutting-edge medical services to our community.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                    SizedBox(height: 24),
                    FooterLink(
                      text: 'Home',
                      onTap: () {
                        final tabController = DefaultTabController.of(context);
                        if (tabController != null) {
                          tabController.animateTo(0);
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                    FooterLink(
                      text: 'Appointments',
                      onTap: () {
                        final tabController = DefaultTabController.of(context);
                        if (tabController != null) {
                          tabController.animateTo(1);
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                    FooterLink(
                      text: 'Feedback',
                      onTap: () {
                        final tabController = DefaultTabController.of(context);
                        if (tabController != null) {
                          tabController.animateTo(2);
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                    FooterLink(
                      text: 'Contact Us',
                      onTap: () {
                        // TODO: Implement scroll to contact section
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contact Us clicked!')),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    Text(
                      '© 2025 Global Care Medical Center. All rights reserved.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Global Care',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Providing compassionate care and cutting-edge medical services to our community.',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Links',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              FooterLink(
                                text: 'Home',
                                onTap: () {
                                  final tabController = DefaultTabController.of(
                                    context,
                                  );
                                  if (tabController != null) {
                                    tabController.animateTo(0);
                                    (context as Element).markNeedsBuild();
                                  }
                                },
                              ),
                              FooterLink(
                                text: 'Appointments',
                                onTap: () {
                                  final tabController = DefaultTabController.of(
                                    context,
                                  );
                                  if (tabController != null) {
                                    tabController.animateTo(1);
                                    (context as Element).markNeedsBuild();
                                  }
                                },
                              ),
                              FooterLink(
                                text: 'Feedback',
                                onTap: () {
                                  final tabController = DefaultTabController.of(
                                    context,
                                  );
                                  if (tabController != null) {
                                    tabController.animateTo(2);
                                    (context as Element).markNeedsBuild();
                                  }
                                },
                              ),
                              FooterLink(
                                text: 'Contact Us',
                                onTap: () {
                                  // TODO: Implement scroll to contact section
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Contact Us clicked!'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              FooterLink(
                                text: 'J. Yulo Avenue, Brgy. Canlubang',
                                icon: Icons.location_on,
                              ),
                              FooterLink(
                                text: '(049) 520-5626',
                                icon: Icons.phone,
                                onTap: () async {
                                  final url = Uri.parse('tel:(049) 520-5626');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot launch phone'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              FooterLink(
                                text: 'gcmccanlubang@gmail.com',
                                icon: Icons.email,
                                onTap: () async {
                                  final url = Uri.parse(
                                    'mailto:gcmccanlubang@gmail.com',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot launch email'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.3)),
                    SizedBox(height: 16),
                    Text(
                      '© 2025 Global Care Medical Center. All rights reserved.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class FooterLink extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;

  FooterLink({required this.text, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
              SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                decoration: onTap != null
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 800),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: isMobile ? 8 : 12),
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1000),
                child: Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class DashboardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final bool isMobile = screenWidth < 600;
            final bool isTablet = screenWidth >= 600 && screenWidth < 900;
            final double cardPadding = isMobile
                ? 12.0
                : isTablet
                ? 16.0
                : 20.0;
            final double sectionSpacing = isMobile
                ? 12.0
                : isTablet
                ? 16.0
                : 20.0;
            final double chartHeight = isMobile
                ? 180.0
                : isTablet
                ? 220.0
                : 260.0;
            final double fontSizeTitle = isMobile
                ? 16.0
                : isTablet
                ? 18.0
                : 20.0;
            final double fontSizeSubtitle = isMobile
                ? 12.0
                : isTablet
                ? 14.0
                : 16.0;

            return Container(
              color: const Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(
                vertical: isMobile
                    ? 16.0
                    : isTablet
                    ? 24.0
                    : 32.0,
                horizontal: screenWidth * 0.05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Welcome Banner
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: _buildWelcomeBanner(
                          context,
                          authService,
                          isMobile,
                          fontSizeTitle,
                          fontSizeSubtitle,
                        ),
                      ),
                    ),
                    SizedBox(height: sectionSpacing),

                    // If not logged in
                    if (!authService.isLoggedIn)
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: _buildLoginPrompt(
                            context,
                            isMobile,
                            cardPadding,
                            fontSizeTitle,
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Overview Section
                          Center(
                            child: SectionHeader(
                              title: 'Dashboard Overview',
                              subtitle:
                                  'Your healthcare insights and management hub.',
                            ),
                          ),
                          SizedBox(height: sectionSpacing),
                          _buildOverviewCharts(
                            context,
                            isMobile,
                            isTablet,
                            cardPadding,
                            chartHeight,
                            fontSizeSubtitle,
                            screenWidth,
                          ),

                          SizedBox(height: sectionSpacing),
                          // User Profile
                          _buildUserProfile(
                            context,
                            authService,
                            isMobile,
                            cardPadding,
                            fontSizeTitle,
                            fontSizeSubtitle,
                          ),

                          SizedBox(height: sectionSpacing),
                          // Appointments
                          Text(
                            'Your Appointments',
                            style: GoogleFonts.poppins(
                              fontSize: fontSizeTitle,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: sectionSpacing / 2),
                          AppointmentHistory(isMobile: isMobile),

                          SizedBox(height: sectionSpacing),
                          // Feedback
                          Text(
                            'Your Feedback',
                            style: GoogleFonts.poppins(
                              fontSize: fontSizeTitle,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: sectionSpacing / 2),
                          _buildFeedbackSection(
                            context,
                            isMobile,
                            cardPadding,
                            fontSizeSubtitle,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeBanner(
    BuildContext context,
    AuthService authService,
    bool isMobile,
    double fontSizeTitle,
    double fontSizeSubtitle,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[700]!, Colors.indigo[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome${authService.isLoggedIn ? ', ${authService.username}' : ''}!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: fontSizeTitle,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: isMobile ? 8.0 : 12.0),
                Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: isMobile ? 28.0 : 32.0,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Your health, our priority. Manage your care with ease.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: fontSizeSubtitle,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(
    BuildContext context,
    bool isMobile,
    double cardPadding,
    double fontSizeTitle,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: isMobile ? 28.0 : 32.0,
              color: Colors.indigo[700],
            ),
            SizedBox(height: 12),
            Text(
              'Please login or sign up to view your dashboard.',
              style: GoogleFonts.poppins(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AuthDialog(),
                );
              },
              child: Text('Login / Sign Up'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20.0 : 24.0,
                  vertical: isMobile ? 10.0 : 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    BuildContext context,
    AuthService authService,
    bool isMobile,
    double cardPadding,
    double fontSizeTitle,
    double fontSizeSubtitle,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Colors.indigo[700],
                size: isMobile ? 24.0 : 28.0,
              ),
              radius: isMobile ? 24.0 : 28.0,
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authService.username ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    authService.email ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: fontSizeSubtitle,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                authService.logout();
                final tabController = DefaultTabController.of(context);
                if (tabController != null) {
                  tabController.animateTo(0);
                  (context as Element).markNeedsBuild();
                }
              },
              icon: Icon(Icons.logout, size: isMobile ? 16.0 : 18.0),
              label: Text('Logout'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12.0 : 16.0,
                  vertical: isMobile ? 6.0 : 8.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCharts(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    double cardPadding,
    double chartHeight,
    double fontSizeSubtitle,
    double screenWidth,
  ) {
    final int crossAxisCount = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isMobile ? 12.0 : 16.0,
          mainAxisSpacing: isMobile ? 12.0 : 16.0,
          childAspectRatio: isMobile
              ? 1.2
              : isTablet
              ? 1.1
              : 1.0,
          children: _buildChartWidgets(
            context,
            isMobile,
            chartHeight,
            fontSizeSubtitle,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChartWidgets(
    BuildContext context,
    bool isMobile,
    double chartHeight,
    double fontSizeSubtitle,
  ) {
    return [
      _buildChartCard(
        context: context,
        isMobile: isMobile,
        title: 'Appointments by Department',
        chart: _buildDepartmentChart(isMobile, chartHeight),
        fontSizeSubtitle: fontSizeSubtitle,
      ),
      _buildChartCard(
        context: context,
        isMobile: isMobile,
        title: 'Patient Satisfaction',
        chart: _buildSatisfactionChart(isMobile, chartHeight),
        fontSizeSubtitle: fontSizeSubtitle,
      ),
      _buildChartCard(
        context: context,
        isMobile: isMobile,
        title: 'Appointment Status',
        chart: _buildStatusChart(isMobile, chartHeight),
        fontSizeSubtitle: fontSizeSubtitle,
      ),
    ];
  }

  Widget _buildChartCard({
    required BuildContext context,
    required bool isMobile,
    required String title,
    required Widget chart,
    required double fontSizeSubtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: fontSizeSubtitle,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: isMobile ? 180.0 : 220.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: chart,
        ),
      ],
    );
  }

  Widget _buildDepartmentChart(bool isMobile, double chartHeight) {
    return SizedBox(
      height: chartHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 200,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipMargin: 10,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                const titles = ['Cardio', 'Neuro', 'Ortho', 'Pedia', 'Derma'];
                return BarTooltipItem(
                  '${titles[group.x]}\n${rod.toY.toInt()}',
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  children: [],
                );
              },
              getTooltipColor: (group) => Colors.indigo[700]!.withOpacity(0.8),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Cardio', 'Neuro', 'Ortho', 'Pedia', 'Derma'];
                  return Text(
                    titles[value.toInt()],
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 8 : 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 8 : 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 120,
                  color: Colors.indigo[700],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 80,
                  color: Colors.indigo[600],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 100,
                  color: Colors.indigo[500],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 150,
                  color: Colors.indigo[400],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: 60,
                  color: Colors.indigo[300],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSatisfactionChart(bool isMobile, double chartHeight) {
    return SizedBox(
      height: chartHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipMargin: 10,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                return BarTooltipItem(
                  '${titles[group.x]}\n${rod.toY.toStringAsFixed(1)}',
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  children: [],
                );
              },
              getTooltipColor: (group) => Colors.indigo[700]!.withOpacity(0.8),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  return Text(
                    titles[value.toInt()],
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 8 : 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 8 : 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 4.2,
                  color: Colors.indigo[700],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 4.3,
                  color: Colors.indigo[600],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 4.5,
                  color: Colors.indigo[500],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 4.1,
                  color: Colors.indigo[400],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: 4.4,
                  color: Colors.indigo[300],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                  toY: 4.6,
                  color: Colors.indigo[200],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart(bool isMobile, double chartHeight) {
    return SizedBox(
      height: chartHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 250,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipMargin: 10,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                const titles = ['Upcoming', 'Completed', 'Cancelled'];
                return BarTooltipItem(
                  '${titles[group.x]}\n${rod.toY.toInt()}',
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  children: [],
                );
              },
              getTooltipColor: (group) => Colors.indigo[700]!.withOpacity(0.8),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Upcoming', 'Completed', 'Cancelled'];
                  return Text(
                    titles[value.toInt()],
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 8 : 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 8 : 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 50,
                  color: Colors.indigo[700],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 200,
                  color: Colors.indigo[600],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 30,
                  color: Colors.indigo[500],
                  width: isMobile ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
    BuildContext context,
    bool isMobile,
    double cardPadding,
    double fontSizeSubtitle,
  ) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Provider.of<FeedbackService>(context).loadFeedback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Center(
                child: Text(
                  'Error loading feedback',
                  style: GoogleFonts.poppins(
                    fontSize: fontSizeSubtitle,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          );
        }
        final feedbackList = snapshot.data ?? [];
        if (feedbackList.isEmpty) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Center(
                child: Text(
                  'No feedback submitted yet.',
                  style: GoogleFonts.poppins(
                    fontSize: fontSizeSubtitle,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbackList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final feedback = feedbackList[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 10.0 : 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: isMobile ? 18.0 : 20.0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rating: ${feedback['rating'].toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(
                            fontSize: fontSizeSubtitle,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback['comment'] ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: fontSizeSubtitle,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submitted on: ${feedback['date'] ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 10.0 : 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
