import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../events/presentation/screens/create_event_screen.dart';
import '../../../qr_scanner/presentation/screens/qr_scanner_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'dashboard_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final user = authNotifier.currentUser;

    // Filter navigation items based on user permissions
    final navigationItems = _getNavigationItems(user);
    final screens = _getScreens(user);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            ref.read(selectedIndexProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondaryColor,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: navigationItems,
        ),
      ),
      floatingActionButton: user?.canCreateEvents == true 
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems(dynamic user) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    ];

    // Events tab (for hosts and admins)
    if (user?.canViewAnalytics == true) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event),
          label: 'Events',
        ),
      );
    }

    // QR Scanner tab (all users)
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.qr_code_scanner_outlined),
        activeIcon: Icon(Icons.qr_code_scanner),
        label: 'Scanner',
      ),
    );

    // Profile tab
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    );

    return items;
  }

  List<Widget> _getScreens(dynamic user) {
    final screens = <Widget>[
      const DashboardScreen(),
    ];

    // Events screen (for hosts and admins)
    if (user?.canViewAnalytics == true) {
      screens.add(const EventsScreen());
    }

    // QR Scanner screen (all users)
    screens.add(const QRScannerScreen());

    // Profile screen
    screens.add(const ProfileScreen());

    return screens;
  }
}

// Custom Bottom Navigation Bar with animations
class AnimatedBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const AnimatedBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<AnimatedBottomNavigationBar> createState() => _AnimatedBottomNavigationBarState();
}

class _AnimatedBottomNavigationBarState extends State<AnimatedBottomNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) =>
        Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
    ).toList();

    // Animate the initially selected item
    _animationControllers[widget.currentIndex].forward();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationControllers[oldWidget.currentIndex].reverse();
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animations[index].value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected 
                                ? (item.activeIcon as Icon).icon 
                                : (item.icon as Icon).icon,
                            color: isSelected 
                                ? AppTheme.primaryColor 
                                : AppTheme.textSecondaryColor,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                              color: isSelected 
                                  ? AppTheme.primaryColor 
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Navigation Helper
class NavigationHelper {
  static void navigateToTab(WidgetRef ref, int index) {
    ref.read(selectedIndexProvider.notifier).state = index;
  }

  static void navigateToDashboard(WidgetRef ref) {
    navigateToTab(ref, 0);
  }

  static void navigateToEvents(WidgetRef ref) {
    navigateToTab(ref, 1);
  }

  static void navigateToScanner(WidgetRef ref) {
    // Find scanner index based on user permissions
    final user = ref.read(authProvider.notifier).currentUser;
    final scannerIndex = user?.canViewAnalytics == true ? 2 : 1;
    navigateToTab(ref, scannerIndex);
  }

  static void navigateToProfile(WidgetRef ref) {
    // Find profile index based on user permissions
    final user = ref.read(authProvider.notifier).currentUser;
    final profileIndex = user?.canViewAnalytics == true ? 3 : 2;
    navigateToTab(ref, profileIndex);
  }
}