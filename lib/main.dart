import 'package:flutter/material.dart';
import 'analytics_screen.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartWaterApp());
}

class SmartWaterApp extends StatelessWidget {
  const SmartWaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Water Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          secondary: Colors.cyanAccent,
          surface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          color: const Color(0x261E293B),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

/// Root mobile screen with bottom navigation tabs
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentUserId = DatabaseHelper.guestUserId;
  String _currentUsername = DatabaseHelper.guestUsername;
  bool _isGuest = true;

  int _selectedTab = 0;
  double _dailyGoal = 60.0;
  List<Map<String, dynamic>> _logs = [];
  double _todayUsage = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAppSession();
  }

  Future<void> _initAppSession() async {
    // Default directly to Guest mode on launch
    final guest = await DatabaseHelper.instance.getGuestUser();
    final goal = await DatabaseHelper.instance.getDailyGoal(guest['id'] as int);

    if (!mounted) return;
    setState(() {
      _currentUserId = guest['id'] as int;
      _currentUsername = guest['username'] as String;
      _isGuest = true;
      _dailyGoal = goal;
    });

    await _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    setState(() => _isLoading = true);

    final data = await DatabaseHelper.instance.fetchLogs(_currentUserId);
    final goal = await DatabaseHelper.instance.getDailyGoal(_currentUserId);

    final nowStr = DateTime.now().toIso8601String().substring(0, 10);
    double todayTotal = 0.0;
    for (var item in data) {
      final timestamp = item['timestamp'] as String? ?? '';
      if (timestamp.startsWith(nowStr)) {
        todayTotal += (item['amount'] as num).toDouble();
      }
    }

    if (!mounted) return;
    setState(() {
      _logs = data;
      _todayUsage = todayTotal;
      _dailyGoal = goal;
      _isLoading = false;
    });
  }

  Future<void> _addWaterLog(String activity, double amount) async {
    await DatabaseHelper.instance.insertLog(_currentUserId, activity, amount);
    await _refreshLogs();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $amount L for $activity'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0369A1),
      ),
    );
  }

  Future<void> _deleteLog(int id) async {
    await DatabaseHelper.instance.deleteLog(id);
    await _refreshLogs();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log deleted'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearAllLogs() async {
    await DatabaseHelper.instance.clearUserLogs(_currentUserId);
    await _refreshLogs();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All logs cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateDailyGoal(double newGoal) async {
    await DatabaseHelper.instance.setDailyGoal(_currentUserId, newGoal);
    setState(() => _dailyGoal = newGoal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Daily target updated to ${newGoal.toStringAsFixed(0)} L'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onUserLoggedIn({
    required int userId,
    required String username,
    required bool transferredGuestData,
  }) async {
    if (transferredGuestData && _isGuest) {
      await DatabaseHelper.instance.transferGuestLogs(userId);
    }

    final userGoal = await DatabaseHelper.instance.getDailyGoal(userId);

    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
      _currentUsername = username;
      _isGuest = false;
      _dailyGoal = userGoal;
    });

    await _refreshLogs();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged in as $username'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.teal.shade700,
      ),
    );
  }

  void _onLogoutToGuest() async {
    final guest = await DatabaseHelper.instance.getGuestUser();
    final guestGoal = await DatabaseHelper.instance.getDailyGoal(guest['id'] as int);

    if (!mounted) return;
    setState(() {
      _currentUserId = guest['id'] as int;
      _currentUsername = guest['username'] as String;
      _isGuest = true;
      _dailyGoal = guestGoal;
    });

    await _refreshLogs();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out. Switched to Guest mode.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuthModalSheet(
        guestLogsCount: _isGuest ? _logs.length : 0,
        onSuccess: (userId, username, transferred) {
          _onUserLoggedIn(
            userId: userId,
            username: username,
            transferredGuestData: transferred,
          );
        },
      ),
    );
  }

  void _showAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWaterLogSheet(
        onAdd: _addWaterLog,
      ),
    );
  }

  void _showSetGoalDialog() {
    final goalController = TextEditingController(text: _dailyGoal.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.tune, color: Colors.cyanAccent),
            SizedBox(width: 10),
            Text('Set Daily Target', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customize your daily target water consumption in Liters.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: goalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Target Limit (Liters)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  suffixText: 'L',
                  suffixStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0x33000000),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final newGoal = double.tryParse(goalController.text.trim());
              if (newGoal != null && newGoal > 0) {
                _updateDailyGoal(newGoal);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save Limit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF075985), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Header Bar
              _buildTopHeader(),

              // Body view based on active tab
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                    : IndexedStack(
                        index: _selectedTab,
                        children: [
                          // Tab 0: Daily Tracker & Quick Actions
                          _buildTrackerTab(),

                          // Tab 1: 7-Day Analytics
                          AnalyticsScreen(
                            userId: _currentUserId,
                            showAppBar: false,
                          ),

                          // Tab 2: Logs & History
                          _buildHistoryTab(),

                          // Tab 3: Account & Settings
                          _buildProfileTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedTab == 0 || _selectedTab == 2
          ? FloatingActionButton.extended(
              onPressed: _showAddEntrySheet,
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log Usage', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.cyanAccent.withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12);
            }
            return const TextStyle(color: Colors.white54, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.cyanAccent);
            }
            return const IconThemeData(color: Colors.white54);
          }),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF0B1329),
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) {
            setState(() => _selectedTab = index);
            if (index == 1) {
              // Refresh when switching to analytics
              setState(() {});
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.water_drop_outlined),
              selectedIcon: Icon(Icons.water_drop),
              label: 'Tracker',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyanAccent.shade400, Colors.blue.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SMART WATER',
                    style: TextStyle(
                      color: Colors.cyanAccent.shade100,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    _isGuest ? 'Guest Mode' : _currentUsername,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // User status action button
          if (_isGuest)
            InkWell(
              onTap: _showAuthModal,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyanAccent.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login_rounded, size: 16, color: Colors.black),
                    SizedBox(width: 5),
                    Text(
                      'Log In',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
                child: Text(
                  _currentUsername.isNotEmpty ? _currentUsername[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ),
              color: const Color(0xFF1E293B),
              onSelected: (value) {
                if (value == 'logout') {
                  _onLogoutToGuest();
                } else if (value == 'switch') {
                  _showAuthModal();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text('Logged in as $_currentUsername',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'switch',
                  child: Row(
                    children: [
                      Icon(Icons.switch_account, color: Colors.cyanAccent, size: 18),
                      SizedBox(width: 8),
                      Text('Switch Account', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text('Log Out to Guest', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTrackerTab() {
    final double percentage = (_dailyGoal > 0 ? (_todayUsage / _dailyGoal) : 0.0).clamp(0.0, 1.0);
    final bool isOverLimit = _todayUsage > _dailyGoal;

    // Filter today's logs for quick view
    final nowStr = DateTime.now().toIso8601String().substring(0, 10);
    final todayLogs = _logs.where((e) {
      final t = e['timestamp'] as String? ?? '';
      return t.startsWith(nowStr);
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guest Encouragement Banner (Non-intrusive)
          if (_isGuest)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x260284C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Browsing as Guest. Tracking is saved locally on your device.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _showAuthModal,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Sign In', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Main Progress Card
          Card(
            color: const Color(0x261E293B),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 94,
                    width: 94,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: percentage,
                          strokeWidth: 9,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverLimit ? Colors.redAccent : Colors.cyanAccent,
                          ),
                        ),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: TextStyle(
                            color: isOverLimit ? Colors.redAccent : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Consumed Today', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          '${_todayUsage.toStringAsFixed(1)} L',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Target: ${_dailyGoal.toStringAsFixed(0)} L',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            InkWell(
                              onTap: _showSetGoalDialog,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  'Edit Limit',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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
          ),
          const SizedBox(height: 16),

          // Quick Add Section (Mobile responsive with Expanded)
          const Text('Quick Add', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Drink',
                  '0.5 L',
                  Icons.local_drink,
                  () => _addWaterLog('Drinking', 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  'Shower',
                  '25 L',
                  Icons.shower,
                  () => _addWaterLog('Shower', 25.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  'Laundry',
                  '40 L',
                  Icons.local_laundry_service,
                  () => _addWaterLog('Laundry', 40.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  'Plants',
                  '5 L',
                  Icons.grass,
                  () => _addWaterLog('Gardening', 5.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's Activity Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Usage', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              if (todayLogs.isNotEmpty)
                Text(
                  '${todayLogs.length} entries',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (todayLogs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0x1F1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.opacity, color: Colors.white30, size: 36),
                  SizedBox(height: 8),
                  Text('No water usage recorded today', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Tap a Quick Add button above or + Log Usage below', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayLogs.length,
              itemBuilder: (context, index) {
                final item = todayLogs[index];
                return _buildLogTile(item);
              },
            ),
          const SizedBox(height: 80), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return _logs.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_damage_outlined, size: 54, color: Colors.white30),
                  const SizedBox(height: 16),
                  const Text('No History Yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Logged activities will appear here chronologically.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Records (${_logs.length})', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: const Color(0xFF1E293B),
                            title: const Text('Clear All Logs?', style: TextStyle(color: Colors.white)),
                            content: const Text('This will delete all saved water logs on this device.', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(c);
                                  _clearAllLogs();
                                },
                                child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.redAccent),
                      label: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final item = _logs[index];
                    return _buildLogTile(item);
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildProfileTab() {
    double lifetimeTotal = 0.0;
    for (var item in _logs) {
      lifetimeTotal += (item['amount'] as num).toDouble();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Info Card
          Card(
            color: const Color(0x261E293B),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isGuest ? Colors.white12 : Colors.cyanAccent.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          _isGuest ? Icons.person_outline : Icons.verified_user,
                          color: _isGuest ? Colors.white70 : Colors.cyanAccent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isGuest ? 'Guest Account' : _currentUsername,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isGuest
                                  ? 'Using offline local storage'
                                  : 'Logged-in user (SQLite local)',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isGuest) ...[
                    const Text(
                      'You are using the app as a guest. You can log in or register anytime to name your account and retain your records.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _showAuthModal,
                        icon: const Icon(Icons.login),
                        label: const Text('Log In / Register', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.cyanAccent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _showAuthModal,
                            icon: const Icon(Icons.switch_account, color: Colors.cyanAccent, size: 18),
                            label: const Text('Switch User', style: TextStyle(color: Colors.cyanAccent)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                              foregroundColor: Colors.redAccent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _onLogoutToGuest,
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Log Out'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daily Target Settings
          Card(
            color: const Color(0x261E293B),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune, color: Colors.cyanAccent, size: 20),
                          SizedBox(width: 8),
                          Text('Daily Consumption Target', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '${_dailyGoal.toStringAsFixed(0)} L',
                        style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _dailyGoal.clamp(10.0, 200.0),
                    min: 10.0,
                    max: 200.0,
                    divisions: 38,
                    activeColor: Colors.cyanAccent,
                    inactiveColor: Colors.white12,
                    label: '${_dailyGoal.toStringAsFixed(0)} L',
                    onChanged: (val) {
                      setState(() => _dailyGoal = val);
                    },
                    onChangeEnd: (val) {
                      _updateDailyGoal(val);
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('10 L (Minimal)', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      Text('200 L (High)', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lifetime Stats Card
          Card(
            color: const Color(0x261E293B),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Usage Statistics', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProfileStatItem('Lifetime Tracked', '${lifetimeTotal.toStringAsFixed(1)} L'),
                      ),
                      Expanded(
                        child: _buildProfileStatItem('Total Entries', '${_logs.length}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProfileStatItem('Database Engine', 'SQLite (Local)'),
                      ),
                      Expanded(
                        child: _buildProfileStatItem('Platform', 'Mobile & Desktop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Eco Conservation Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x260284C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amberAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Water Saving Fact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Turning off the tap while brushing your teeth can save up to 8 liters of water per day!',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, String amount, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0x261E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 22),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(Map<String, dynamic> item) {
    final activity = item['activity'] as String? ?? 'Water Usage';
    final amount = (item['amount'] as num).toDouble();
    final rawTimestamp = item['timestamp'] as String? ?? '';
    final id = item['id'] as int;

    String dateDisplay = rawTimestamp;
    if (rawTimestamp.contains('T')) {
      final parts = rawTimestamp.split('T');
      final datePart = parts[0];
      final timePart = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
      dateDisplay = '$datePart • $timePart';
    }

    IconData icon = Icons.water_drop;
    if (activity.toLowerCase().contains('drink')) icon = Icons.local_drink;
    if (activity.toLowerCase().contains('shower')) icon = Icons.shower;
    if (activity.toLowerCase().contains('laundry')) icon = Icons.local_laundry_service;
    if (activity.toLowerCase().contains('garden') || activity.toLowerCase().contains('plant')) {
      icon = Icons.grass;
    }

    return Card(
      color: const Color(0x1F1E293B),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: Colors.cyanAccent.withValues(alpha: 0.15),
          child: Icon(icon, color: Colors.cyanAccent, size: 20),
        ),
        title: Text(
          activity,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          dateDisplay,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x330284C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${amount.toStringAsFixed(1)} L',
                style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 19),
              onPressed: () => _deleteLog(id),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile Bottom Sheet for adding custom water logs
class AddWaterLogSheet extends StatefulWidget {
  final Future<void> Function(String activity, double amount) onAdd;

  const AddWaterLogSheet({super.key, required this.onAdd});

  @override
  State<AddWaterLogSheet> createState() => _AddWaterLogSheetState();
}

class _AddWaterLogSheetState extends State<AddWaterLogSheet> {
  final _activityController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _commonActivities = [
    'Drinking',
    'Shower',
    'Cooking',
    'Dishwashing',
    'Laundry',
    'Gardening',
    'Car Wash',
  ];

  @override
  void dispose() {
    _activityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addQuickPreset(double val) {
    final current = double.tryParse(_amountController.text.trim()) ?? 0.0;
    _amountController.text = (current + val).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.cyanAccent),
                    SizedBox(width: 8),
                    Text('Log Water Usage', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),

                // Suggestion chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _commonActivities.map((act) {
                    return ActionChip(
                      label: Text(act, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: const Color(0x260284C7),
                      side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () {
                        setState(() => _activityController.text = act);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _activityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Activity Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0x33000000),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter activity' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount (Liters)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    suffixText: 'L',
                    suffixStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: const Color(0x33000000),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter amount';
                    final parsed = double.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) return 'Enter valid positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Quick amount increment buttons
                Row(
                  children: [
                    const Text('Quick add:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(width: 8),
                    _buildIncrementChip('+0.5L', 0.5),
                    const SizedBox(width: 6),
                    _buildIncrementChip('+1L', 1.0),
                    const SizedBox(width: 6),
                    _buildIncrementChip('+5L', 5.0),
                    const SizedBox(width: 6),
                    _buildIncrementChip('+20L', 20.0),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final act = _activityController.text.trim();
                        final amt = double.parse(_amountController.text.trim());
                        await widget.onAdd(act, amt);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Entry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncrementChip(String label, double val) {
    return InkWell(
      onTap: () => _addQuickPreset(val),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Mobile Modal Bottom Sheet for optional Login & Register ("like usual applications")
class AuthModalSheet extends StatefulWidget {
  final int guestLogsCount;
  final Function(int userId, String username, bool transferredGuestData) onSuccess;

  const AuthModalSheet({
    super.key,
    required this.guestLogsCount,
    required this.onSuccess,
  });

  @override
  State<AuthModalSheet> createState() => _AuthModalSheetState();
}

class _AuthModalSheetState extends State<AuthModalSheet> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _transferGuestData = true;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill out both username and password');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        final user = await DatabaseHelper.instance.loginUser(username, password);
        if (!mounted) return;
        if (user != null) {
          final userId = user['id'] as int;
          widget.onSuccess(userId, username, _transferGuestData);
          Navigator.pop(context);
        } else {
          setState(() {
            _error = 'Invalid username or password';
            _submitting = false;
          });
        }
      } else {
        final userId = await DatabaseHelper.instance.registerUser(username, password);
        if (!mounted) return;
        widget.onSuccess(userId, username, _transferGuestData);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _isLogin ? 'Login failed' : 'Username already exists';
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title and toggle
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _isLogin
                    ? 'Log in to access your personal profile'
                    : 'Register an account to sync your logs',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 18),

              // Mode toggle tab
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _isLogin = true;
                          _error = null;
                        }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.cyanAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: _isLogin ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _isLogin = false;
                          _error = null;
                        }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.cyanAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: !_isLogin ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.person, color: Colors.white54, size: 20),
                  filled: true,
                  fillColor: const Color(0x33000000),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white54, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: const Color(0x33000000),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),

              // Option to transfer guest logs
              if (widget.guestLogsCount > 0) ...[
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _transferGuestData,
                  activeColor: Colors.cyanAccent,
                  checkColor: Colors.black,
                  dense: true,
                  title: Text(
                    'Keep my ${widget.guestLogsCount} guest water logs in this account',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _transferGuestData = val ?? true),
                ),
              ],
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Dismiss / continue as guest
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue as Guest', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}