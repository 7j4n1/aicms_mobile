import 'package:aicms_mobile/models/account_balance.dart';
import 'package:aicms_mobile/models/transaction.dart';

class AccountService {
  Future<AccountBalance> getBalances() async {
    await Future.delayed(const Duration(seconds: 2));
    return const AccountBalance(
      totalBalance: 10000000000.00,
      savings: 50000000.00,
      shares: 30000000.00,
      loan: 20000000.00,
    );
  }

  Future<List<Transaction>> getRecentTransactions() async {
    await Future.delayed(const Duration(seconds: 2));
    return const [
      Transaction(
        id: '1',
        date: '2021-09-01',
        amount: -30000.00,
      ),
      Transaction(
        id: '2',
        date: '2021-09-02',
        amount: -20000.00,
      ),
      Transaction(
        id: '3',
        date: '2021-09-03',
        amount: 50000.00,
      ),
      Transaction(
        id: '4',
        date: '2021-09-04',
        amount: -20000.00,
      ),
      Transaction(
        id: '5',
        date: '2021-09-05',
        amount: 10000.00,
      ),
      Transaction(
        id: '6',
        date: '2021-09-06',
        amount: -10000.00,
      ),
      Transaction(
        id: '7',
        date: '2021-09-07',
        amount: -20000.00,
      ),
    ];
  }
}
