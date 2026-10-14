import 'package:get/get.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/customer_service.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/sale_model.dart';

class DebtController extends GetxController {
  final SaleService _saleService = Get.find<SaleService>();
  final CustomerService _customerService = Get.find<CustomerService>();

  final RxMap<String, int> customerDebts = <String, int>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'belum_lunas'.obs; // 'belum_lunas', 'lunas', 'semua'
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDebts();
  }

  Future<void> fetchDebts() async {
    isLoading.value = true;
    final debts = await _saleService.getDebtsByCustomer();
    customerDebts.assignAll(debts);
    isLoading.value = false;
  }

  int get totalActiveDebt {
    return customerDebts.values.fold(0, (sum, val) => sum + val);
  }

  /// Daftar pelanggan yang memiliki sisa piutang aktif (> 0)
  List<CustomerModel> get customersWithDebt {
    if (customerDebts.isEmpty) return [];
    final List<CustomerModel> list = [];
    final existingMap = {for (var c in _customerService.customers) c.id: c};

    for (var entry in customerDebts.entries) {
      if (entry.value <= 0) continue;
      final cid = entry.key;

      if (existingMap.containsKey(cid)) {
        list.add(existingMap[cid]!);
      } else if (cid == 'general' || cid.isEmpty) {
        list.add(CustomerModel(
          id: 'general',
          name: 'Pelanggan Umum (Tanpa Akun)',
          phone: '-',
          type: 'general',
          createdAt: DateTime.now(),
        ));
      } else {
        // Coba cari nama pelanggan dari transaksi jika ada
        final sale = _saleService.sales.firstWhereOrNull((s) => s.customerId == cid);
        final name = (sale != null && sale.customerType == 'vip')
            ? 'Pelanggan VIP ($cid)'
            : 'Pelanggan (${cid.length > 8 ? cid.substring(0, 8) : cid})';
        list.add(CustomerModel(
          id: cid,
          name: name,
          phone: '-',
          type: 'vip',
          createdAt: DateTime.now(),
        ));
      }
    }
    return list;
  }

  /// Daftar pelanggan yang riwayat piutangnya sudah LUNAS (pernah berhutang tapi sisa 0)
  List<CustomerModel> get customersWithPaidDebt {
    final List<CustomerModel> list = [];
    final existingMap = {for (var c in _customerService.customers) c.id: c};

    // Ambil customerId dari semua sales yang pernah ada cicilan / hutang tapi sekarang lunas
    final Set<String> paidCustomerIds = {};
    for (var s in _saleService.sales) {
      if (s.transactionStatus != 'voided' && s.remainingAmount <= 0) {
        // Jika pembayaran pernah sebagian atau metode cicilan
        if (s.paymentStatus.toLowerCase() == 'lunas' && s.customerId != null) {
          if (!customerDebts.containsKey(s.customerId) || (customerDebts[s.customerId] ?? 0) <= 0) {
            paidCustomerIds.add(s.customerId!);
          }
        }
      }
    }

    for (var cid in paidCustomerIds) {
      if (existingMap.containsKey(cid)) {
        list.add(existingMap[cid]!);
      }
    }
    return list;
  }

  /// Daftar yang disaring sesuai tab filter dan kata kunci pencarian
  List<CustomerModel> get filteredCustomers {
    List<CustomerModel> baseList;
    if (selectedFilter.value == 'belum_lunas') {
      baseList = customersWithDebt;
    } else if (selectedFilter.value == 'lunas') {
      baseList = customersWithPaidDebt;
    } else {
      // Semua
      final all = <CustomerModel>[...customersWithDebt];
      for (var p in customersWithPaidDebt) {
        if (!all.any((c) => c.id == p.id)) {
          all.add(p);
        }
      }
      baseList = all;
    }

    if (searchQuery.value.trim().isEmpty) return baseList;
    final query = searchQuery.value.trim().toLowerCase();
    return baseList.where((c) => c.name.toLowerCase().contains(query) || c.phone.contains(query)).toList();
  }

  Future<List<SaleModel>> getUnpaidSalesFor(String customerId) async {
    return await _saleService.getUnpaidSalesForCustomer(customerId);
  }

  Future<List<SaleModel>> getAllSalesFor(String customerId) async {
    return await _saleService.getAllSalesForCustomer(customerId);
  }

  Future<void> payDebt(String saleId, int amount) async {
    await _saleService.payDebt(saleId, amount, 'Cash');
    await fetchDebts(); // Refresh data
  }
}
