import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../dashboard/dashboard_screen.dart';
import '../orders/orders_screen.dart';
import '../inventory/inventory_screen.dart';
import '../finance/finance_screen.dart';
import '../tasks/tasks_screen.dart';
import '../notes/notes_screen.dart';
import '../goals/goals_screen.dart';
import '../../core/constants/app_colors.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OrdersScreen(),
    const InventoryScreen(),
    const FinanceScreen(),
    const TasksScreen(),
    const NotesScreen(),
    const GoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: BottomNavigationBar(
              currentIndex: _selectedIndex >= 5 ? 4 : _selectedIndex, // Grouping for simple nav if needed
              onTap: (index) {
                if (index == 4) {
                   _showMoreMenu();
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.luxuryGold,
              unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
              iconSize: 20,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Orders'),
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Inventory'),
                BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments), label: 'Finance'),
                BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMoreItem(4, 'Tasks', Icons.check_circle_outline),
            _buildMoreItem(5, 'Notes', Icons.note_alt_outlined),
            _buildMoreItem(6, 'Goals', Icons.auto_awesome_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreItem(int index, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.luxuryGold, size: 22.w),
      title: Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
