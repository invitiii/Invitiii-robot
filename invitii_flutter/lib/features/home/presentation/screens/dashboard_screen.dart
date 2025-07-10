import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/rsvp.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/quick_actions.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.notifier).currentUser;
    final events = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(eventsProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, user),
                const SizedBox(height: AppTheme.spacingLarge),
                
                // Quick Actions (for hosts)
                if (user?.canCreateEvents == true) ...[
                  const QuickActions(),
                  const SizedBox(height: AppTheme.spacingLarge),
                ],
                
                // Analytics Cards
                events.when(
                  data: (eventsList) => _buildAnalyticsCards(eventsList),
                  loading: () => _buildLoadingCards(),
                  error: (error, stack) => _buildErrorCard(error),
                ),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                // Recent Events/Activity
                events.when(
                  data: (eventsList) => _buildRecentActivity(eventsList),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    final timeOfDay = _getTimeOfDay();
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$timeOfDay${user?.displayName != null ? ", ${user!.displayName}" : ""}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXSmall),
              Text(
                'Welcome to ${AppConstants.appName}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // Profile Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
          ),
          child: user?.hasProfileImage == true
              ? ClipOval(
                  child: Image.network(
                    user!.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialsAvatar(user.initials);
                    },
                  ),
                )
              : _buildInitialsAvatar(user?.initials ?? 'U'),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildAnalyticsCards(List<Event> events) {
    final totalEvents = events.length;
    final upcomingEvents = events.where((e) => e.isUpcoming).length;
    final totalGuests = events.fold<int>(0, (sum, e) => sum + e.totalGuests);
    final totalRSVPs = events.fold<int>(0, (sum, e) => sum + e.confirmedCount);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        
        // First row
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Total Events',
                value: totalEvents.toString(),
                icon: Icons.event,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: DashboardCard(
                title: 'Upcoming',
                value: upcomingEvents.toString(),
                icon: Icons.schedule,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        
        // Second row
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Total Guests',
                value: totalGuests.toString(),
                icon: Icons.people,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: DashboardCard(
                title: 'Confirmed RSVPs',
                value: totalRSVPs.toString(),
                icon: Icons.check_circle,
                color: AppTheme.rsvpYesColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorCard(Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 48,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Unable to load analytics',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Pull down to refresh',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Event> events) {
    final recentEvents = events.take(3).toList();
    
    if (recentEvents.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Events',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to events tab
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        
        ...recentEvents.map((event) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
          child: RecentActivityCard(event: event),
        )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          
          Text(
            'No Events Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          
          Text(
            'Create your first event to get started with digital invitations',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create event
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Provider for sample events (replace with real API call)
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  // Simulate API delay
  await Future.delayed(const Duration(seconds: 1));
  
  // Return sample data
  return SampleEvents.sampleEvents;
});