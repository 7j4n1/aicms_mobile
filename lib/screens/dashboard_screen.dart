import 'package:aicms_mobile/models/account_balance.dart';
import 'package:aicms_mobile/models/transaction.dart';
import 'package:aicms_mobile/services/account_service.dart';
import 'package:aicms_mobile/theme/app_theme.dart';
import 'package:aicms_mobile/widgets/shimmer_loading.dart';
import 'package:aicms_mobile/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';
import 'package:aicms_mobile/widgets/balance_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AccountService _accountService = AccountService();
  late Future<AccountBalance> _balancesFuture;
  late Future<List<Transaction>> _recentTransactionsFuture;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _balancesFuture = _accountService.getBalances();
      _recentTransactionsFuture = _accountService.getRecentTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true, // Center the title for better appearance
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
              child: Icon(Icons.person, size: 18),
            ),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20.0), // Increased vertical padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Wider horizontal padding
                child: Text(
                  'ACCOUNT SUMMARY',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 12), // Increased spacing
              
              // Total Balance Card
              FutureBuilder<AccountBalance>(
                future: _balancesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0), // Wider padding
                      child: ShimmerLoading(height: 100), // Increased height
                    );
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget('Failed to load balance data');
                  } else if (snapshot.hasData) {
                    final balances = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Wider padding
                      child: Card(
                        color: AppTheme.primaryColor,
                        elevation: 6, // Increased elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Rounder corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0), // Increased padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Balance',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600, // Slightly bolder
                                    ),
                                  ),
                                  Container( // Circular background for icon
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12), // More spacing
                              Text(
                                '₦${balances.totalBalance.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return _buildErrorWidget('No balance data available');
                  }
                },
              ),
              
              const SizedBox(height: 24), // More spacing between elements
              
              // Account Category Cards
              FutureBuilder<AccountBalance>(
                future: _balancesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: List.generate(3, (index) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 4.0 : 4.0,
                              right: index == 2 ? 4.0 : 4.0,
                            ),
                            child: const ShimmerLoading(height: 120), // Increased height
                          ),
                        )),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget('Failed to load detail balances');
                  } else if (snapshot.hasData) {
                    final balances = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: BalanceCard(
                              title: 'Savings',
                              amount: balances.savings,
                              icon: Icons.savings,
                              gradientColors: const [
                                Color(0xFF1976D2),
                                Color(0xFF64B5F6),
                              ],
                              onTap: () => Navigator.of(context).pushReplacementNamed(
                                '/records', 
                                arguments: {
                                  'tabIndex': 0,
                                }
                              ),
                            ),
                          ),
                          Expanded(
                            child: BalanceCard(
                              title: 'Shares',
                              amount: balances.shares,
                              icon: Icons.pie_chart,
                              gradientColors: const [
                                Color(0xFF7B1FA2),
                                Color(0xFFBA68C8),
                              ],
                              onTap: () => Navigator.of(context).pushReplacementNamed('/records', arguments: {
                                  'tabIndex': 1,
                                }),
                            ),
                          ),
                          Expanded(
                            child: BalanceCard(
                              title: 'Loan',
                              amount: balances.loan,
                              icon: Icons.account_balance,
                              gradientColors: const [
                                Color(0xFFEF6C00),
                                Color(0xFFFFB74D),
                              ],
                              onTap: () => Navigator.of(context).pushReplacementNamed(
                                '/records',
                                arguments: {
                                  'tabIndex': 2,
                                }
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return _buildErrorWidget('No balance data available');
                  }
                },
              ),
              
              const SizedBox(height: 30), // Increased spacing
              
              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Wider padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT TRANSACTIONS',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/records'),
                      icon: const Icon(Icons.chevron_right, size: 20),
                      label: Text(
                        'View All',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Recent Transactions List
              FutureBuilder<List<Transaction>>(
                future: _recentTransactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: ShimmerLoading(height: 80),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget('Failed to load transactions');
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final transactions = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length > 5 ? 5 : transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionListItem(
                          transaction: transactions[index],
                          onTap: () => {}
                          ,
                        );
                      },
                    );
                  } else {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recent transactions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 32), // More spacing
              
              // Submit Payment Record Button
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/submit-payment');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18.0), // Taller button
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: AppTheme.accentColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.payment, size: 24),
                      label: const Text(
                        'Submit Payment Record',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/records');
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/reports');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/more');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            TextButton(
              onPressed: () {
                _refreshKey.currentState?.show();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
