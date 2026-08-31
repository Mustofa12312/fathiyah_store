# 1. 🔴 KEAMANAN FIRESTORE SANGAT KRITIS

Ini adalah masalah nomor satu.

`firestore.rules` saat ini mempunyai:

```text
match /{document=**} {
  allow read, write: if true;
}
```

Artinya **siapa pun yang bisa mengakses Firebase project dapat membaca dan menulis seluruh data Firestore**. Bahkan file tersebut sendiri menjelaskan bahwa rule ini masih temporary/insecure karena Firebase Authentication belum digunakan.

Lebih parah lagi, rule RBAC yang sebenarnya justru masih berada dalam komentar.

Akibatnya data seperti:

- produk
- stok
- transaksi
- pelanggan
- piutang
- pengeluaran
- user
- audit log
- shift

tidak benar-benar dilindungi oleh role.

### Dampaknya

Orang yang mengetahui konfigurasi Firebase dapat berpotensi:

- membaca data pelanggan;
- mengubah harga;
- mengubah stok;
- mengubah transaksi;
- mengubah piutang;
- membuat user admin;
- menghapus/mengubah data;
- memanipulasi laporan.

**Prioritas: P0 — wajib diperbaiki sebelum production.**

---

# 2. 🔴 SISTEM LOGIN BUKAN AUTHENTICATION SEBENARNYA

Ini lebih serius daripada sekadar masalah login.

`UserModel` menyimpan:

```text
username
password
role
status
```

dan password disimpan langsung sebagai field biasa.

Bahkan `AuthService` membuat akun:

```text
username: admin
password: 123
```

secara otomatis jika collection user kosong. ([GitHub][2])

Ini bukan authentication yang aman.

Seharusnya:

```text
Firebase Authentication
        ↓
UID
        ↓
users/{uid}
        ↓
role / permission
```

bukan:

```text
Firestore
   ↓
username + password
```

### Masalah tambahannya

Password plaintext berarti kalau database terbaca:

> seluruh password pengguna langsung diketahui.

Tidak boleh seperti ini.

---

# 3. 🔴 RBAC HANYA ADA DI LEVEL APLIKASI, BUKAN SECURITY LAYER

PRD sudah sangat bagus dalam mendefinisikan:

- Owner
- Admin
- Kasir
- Permission

Bahkan PRD menjelaskan kasir tidak boleh menghapus produk, mengubah harga, mengelola user, dan sebagainya. ([GitHub][3])

Tetapi database belum benar-benar menegakkan aturan tersebut.

Ini perbedaan besar:

### Sekadar UI

```dart
if (user.isAdmin)
   showDeleteButton();
```

belum cukup.

Karena user bisa melewati UI dan langsung mengirim request ke Firestore.

Yang dibutuhkan:

```text
UI permission
       +
Application permission
       +
Firestore Security Rules
```

Ketiganya harus konsisten.

---

# 4. 🔴 TRANSAKSI TIDAK ATOMIC

Ini salah satu masalah paling penting di `SaleService`.

Flow sekarang kira-kira:

```text
Create sale
   ↓
Update product stock
   ↓
Record stock movement
   ↓
Update shift
```

dan semuanya dilakukan satu per satu.

Contohnya:

```text
Sale berhasil disimpan
        ↓
Stock update gagal
        ↓
Transaksi ada
        ↓
Stok tidak berubah
```

Atau:

```text
Stock produk A berhasil
Stock produk B gagal
```

Maka database menjadi tidak konsisten.

Untuk POS, ini sangat berbahaya.

Idealnya menggunakan:

```text
Firestore Transaction
atau
Batch Write
```

untuk operasi yang harus konsisten.

---

# 5. 🔴 RACE CONDITION PADA STOK

Misalnya stok:

```text
Kopi = 1
```

Kasir A dan Kasir B melakukan transaksi hampir bersamaan.

Keduanya membaca:

```text
stock = 1
```

Kemudian keduanya melakukan:

```text
stock - 1
```

Hasil akhirnya bisa menjadi:

```text
stock = 0
```

padahal:

```text
2 transaksi berhasil
```

Artinya ada barang terjual dua kali.

Ini merupakan masalah klasik pada sistem POS multi-kasir.

Perlu mekanisme atomic transaction/optimistic concurrency.

---

# 6. 🔴 PEMBAYARAN PIUTANG BELUM MEMILIKI PAYMENT LEDGER

`payDebt()` hanya mengubah:

```text
paidAmount
remainingAmount
paymentStatus
```

pada transaksi.

Padahal PRD menyebutkan:

> setiap pembayaran harus disimpan sebagai riwayat pembayaran. ([GitHub][3])

Idealnya ada collection:

```text
payments
```

misalnya:

```text
payment_id
sale_id
customer_id
amount
payment_method
cashier_id
created_at
shift_id
reference
note
```

Dengan begitu:

```text
Transaksi
Rp100.000

Pembayaran #1
Rp30.000

Pembayaran #2
Rp20.000

Pembayaran #3
Rp50.000
```

bisa diaudit dengan jelas.

Saat ini informasi pembayaran lanjutan tersebut tidak direkam sebagai ledger tersendiri.

---

# 7. 🔴 JUMLAH PEMBAYARAN TIDAK DIVALIDASI DENGAN KUAT

`processCheckout()` menghitung:

```dart
remaining = total - paidAmount;
```

tetapi tidak terlihat adanya validasi kuat untuk memastikan:

```text
paidAmount >= 0
paidAmount <= total
```

Jika:

```text
paidAmount = 500000
total = 100000
```

sistem malah membuat:

```text
remaining = 0
```

dan status:

```text
lunas
```

Padahal seharusnya kelebihan pembayaran menjadi:

```text
kembalian = 400000
```

Ini sangat penting untuk POS cash.

---

# 8. 🔴 LOGIKA UANG MENGGUNAKAN `double`

Harga dan transaksi menggunakan tipe:

```dart
double
```

Contohnya `paidAmount`, `total`, `sellingPrice`, dan sebagainya.

Untuk sistem keuangan, sebaiknya jangan mengandalkan floating point.

Lebih aman menyimpan:

```text
10000 rupiah
```

sebagai:

```text
int 10000
```

atau integer dalam satuan terkecil.

Misalnya:

```text
price = 12500
```

bukan:

```text
price = 12500.0
```

Ini mencegah masalah precision floating point.

---

# 9. 🔴 PERHITUNGAN SHIFT JUGA RENTAN TIDAK KONSISTEN

`recordCashSale()` mengambil nilai shift sekarang:

```text
shift.totalSalesCash
```

kemudian melakukan:

```text
old + amount
```

dan update kembali.

Jika dua transaksi terjadi bersamaan, kemungkinan terjadi lost update.

Contoh:

```text
Current = 100.000

Kasir A membaca 100.000
Kasir B membaca 100.000

A → 150.000
B → 175.000
```

Seharusnya:

```text
225.000
```

tetapi bisa berakhir:

```text
175.000
```

Solusinya adalah ledger transaksi kas atau atomic increment/transaction.

---

# 10. 🔴 SHIFT BELUM MEMILIKI REKONSILIASI KAS YANG KUAT

Shift sekarang mempunyai:

```text
startBalance
totalSalesCash
totalExpensesCash
endBalance
```

Namun konsep POS profesional seharusnya mempunyai:

```text
Saldo awal
+ penjualan cash
+ pembayaran piutang cash
+ pemasukan lain
- pengeluaran cash
- refund
= expected cash
```

Kemudian:

```text
actual cash
-
expected cash
=
selisih
```

Dan selisih harus dicatat.

Saat ini fondasinya ada, tetapi rekonsiliasi kasnya belum cukup kuat.

---

# 11. 🔴 BACKUP BUKAN BACKUP DATABASE SEBENARNYA

`BackupService` mengekspor:

- products
- customers
- sales

ke CSV.

Masalahnya, data penting lain tidak ikut dibackup secara lengkap, misalnya:

- users
- categories
- expenses
- shifts
- stock movements
- audit logs
- payments/debt history
- shop settings

Jadi istilah:

> "Backup Database"

agak misleading.

Ini sebenarnya lebih tepat:

> **Data Export**

Backup production seharusnya bisa memulihkan keseluruhan state aplikasi.

---

# 12. 🔴 RESTORE DATA TERLALU BERISIKO

Import menggunakan:

```dart
batch.set(..., SetOptions(merge: true))
```

dan dapat langsung menulis data ke Firestore.

Belum terlihat mekanisme seperti:

```text
Preview
↓
Validate
↓
Conflict detection
↓
Confirmation
↓
Backup current data
↓
Restore
```

Bayangkan admin memasukkan CSV yang salah.

Bisa terjadi:

```text
Database
↓
overwrite
↓
data rusak
```

Sebaiknya restore memiliki:

- preview;
- jumlah record;
- duplicate detection;
- validation;
- dry-run;
- confirmation;
- rollback strategy.

---

# 13. 🟠 BACKUP TIDAK MENYIMPAN DETAIL ITEM TRANSAKSI

Export sales hanya mencatat:

```text
ID
Waktu
Kasir
Pelanggan
Total
Dibayar
Sisa
Status
```

Tetapi tidak mencatat:

```text
barang apa
quantity berapa
harga berapa
subtotal berapa
```

Jadi jika database asli hilang, backup tersebut **tidak cukup untuk merekonstruksi transaksi secara lengkap**.

---

# 14. 🟠 ARSITEKTUR DATA MASIH TERLALU TERGANTUNG PADA CLIENT

Banyak business logic dilakukan di Flutter.

Contohnya:

```text
calculate total
calculate remaining
update stock
record stock movement
record cash
```

Ini membuat client menjadi terlalu dipercaya.

Dalam aplikasi production:

```text
Flutter
   ↓
request
   ↓
trusted business logic
   ↓
database
```

harus menjadi prinsip utama untuk operasi kritis.

---

# 15. 🟠 GETX SERVICE TERLALU BANYAK DI-INJECT SEBAGAI `permanent`

Di `main.dart`, hampir semua service dibuat:

```dart
Get.put(..., permanent: true)
```

mulai dari:

- AuthService
- StockMovementService
- AuditLogService
- ShiftService
- ProductRepository
- CustomerRepository
- ShopService
- CategoryService
- ProductService
- CustomerService
- SaleService
- ExpenseService
- PrinterService
- BackupService.

Ini memang mudah, tetapi membuat dependency lifecycle menjadi terlalu global.

Semakin besar aplikasi, semakin sulit:

- testing;
- debugging;
- dependency management;
- memory lifecycle;
- isolasi module.

---

# 16. 🟠 `main.dart` TERLALU BANYAK MENGETAHUI DEPENDENCY GRAPH

Komentarnya bahkan secara eksplisit membagi:

```text
Layer 1
Layer 2
Layer 3
Layer 4
```

dan melakukan initialization manual.

Ini akan menjadi masalah ketika jumlah service bertambah.

Lebih baik menggunakan:

```text
bindings
dependency injection
module-level bindings
```

sehingga initialization tidak menumpuk di `main.dart`.

---

# 17. 🟠 `.env` Dimasukkan Sebagai Flutter Asset

`pubspec.yaml` memasukkan:

```yaml
assets:
  - .env
```

Ini harus diperhatikan.

Kalau `.env` berisi sesuatu yang dianggap secret, memasukkannya sebagai asset berarti informasi tersebut bisa ikut masuk ke aplikasi.

Dan perlu diingat:

> secret di aplikasi mobile pada dasarnya tidak benar-benar secret.

Credential yang benar-benar sensitif harus berada di server/Cloud Functions/backend.

---

# 18. 🟠 CACHE FIRESTORE `UNLIMITED`

Aplikasi mengaktifkan:

```dart
cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
```

Untuk aplikasi toko dengan data yang terus bertambah, ini perlu dipertimbangkan ulang.

Data:

```text
sales
audit
stock movements
```

bisa berkembang sangat besar.

Lebih baik menentukan strategi:

```text
offline cache
retention
pagination
historical archive
```

daripada unlimited tanpa strategi.

---

# 19. 🟠 SEMUA DATA SALES DI-LISTEN SECARA REAL-TIME

`SaleService` melakukan:

```text
sales
.orderBy(createdAt)
.snapshots()
```

dan memuat semua sales ke:

```dart
sales.value
```

Ini sangat bermasalah ketika toko sudah mempunyai:

```text
10.000 transaksi
50.000 transaksi
100.000 transaksi
```

Aplikasi tidak seharusnya memuat seluruh history transaksi ke memory.

Harus menggunakan:

```text
pagination
limit
date filtering
cursor pagination
aggregation
```

---

# 20. 🟠 PERHITUNGAN PIUTANG DILAKUKAN DI CLIENT

`getDebtsByCustomer()` melakukan loop:

```text
for every sale
```

kemudian menjumlahkan piutang.

Ini masih oke ketika:

```text
100 transaksi
```

tetapi buruk ketika:

```text
100.000 transaksi
```

Perlu struktur data/aggregation yang lebih tepat:

```text
customer balance
```

atau query terfilter.

---

# 21. 🟠 MODEL DATA BELUM CUKUP "ACCOUNTING-GRADE"

Untuk POS sederhana, struktur sekarang cukup.

Tetapi kalau Fathiyah Store ingin menjadi sistem yang benar-benar dapat dipercaya, perlu memisahkan:

```text
Sale
Sale Item
Payment
Refund
Expense
Stock Movement
Cash Movement
Shift
Audit Log
```

Jangan terlalu banyak menjadikan satu dokumen transaksi sebagai sumber semua informasi.

---

# 22. 🟠 BELUM TERLIHAT MEKANISME REFUND YANG KUAT

PRD memang menyebut:

```text
Retur
```

dalam stock movement. ([GitHub][3])

Tetapi refund/return bukan sekadar:

```text
stock + 1
```

Harus ada:

```text
original_sale
return_items
return_quantity
refund_amount
refund_method
reason
cashier
approved_by
created_at
```

Kalau tidak, laporan penjualan dan stok bisa tidak sinkron.

---

# 23. 🟠 BELUM ADA VOID/CANCEL TRANSACTION YANG BENAR

POS production harus membedakan:

```text
Delete
Void
Cancel
Refund
Return
Correction
```

Jangan menghapus transaksi.

Contoh:

```text
TRX-001
Rp100.000
```

kemudian dihapus.

Lebih baik:

```text
TRX-001
status = VOID
voidedBy = admin
voidedAt = ...
reason = ...
```

Dengan demikian audit trail tetap ada.

---

# 24. 🟠 AUDIT LOG HARUS DIANGGAP SEBAGAI DATA KRITIS

Sudah ada `AuditLogService`, ini bagus.

Tetapi audit log tidak boleh hanya menjadi:

```text
UI feature
```

Harus mencatat perubahan kritis seperti:

```text
LOGIN
LOGOUT
CREATE_PRODUCT
CHANGE_PRICE
STOCK_ADJUSTMENT
VOID_TRANSACTION
REFUND
CREATE_USER
CHANGE_ROLE
CHANGE_PERMISSION
PAY_DEBT
EXPENSE
SHIFT_OPEN
SHIFT_CLOSE
BACKUP
RESTORE
```

Dan yang paling penting:

> kasir tidak boleh dapat memanipulasi audit log miliknya sendiri.

---

# 25. 🟠 STRUKTUR PRD BAGUS, TETAPI IMPLEMENTASI BELUM SEPENUHNYA MATCH

Ini menarik.

PRD Fathiyah Store sebenarnya sudah cukup matang: mencakup POS, stok, pelanggan VIP, piutang, pembayaran, shift, laporan, audit, multi-user, dan permission. ([GitHub][3])

Masalahnya:

> **PRD lebih matang daripada security dan data architecture yang mengimplementasikannya.**

Jadi sekarang bukan waktunya menambah banyak fitur baru.

Lebih tepat:

**rapikan fondasi → baru tambah fitur.**

---

# 26. 🟡 UI THEME SUDAH BAGUS SEBAGAI FOUNDATION, TAPI BELUM CUKUP SEBAGAI DESIGN SYSTEM

Theme menggunakan:

- Slate;
- Blue;
- Emerald;
- Amber untuk VIP;
- Inter;
- rounded card;
- rounded button.

Ini sudah cukup modern.

Tetapi design system sebaiknya dibuat lebih lengkap:

```text
Colors
Typography
Spacing
Radius
Elevation
Iconography
Button states
Input states
Empty states
Loading states
Error states
Success states
```

Jangan setiap halaman menentukan style sendiri.

---

# 27. 🟡 UX KASIR PERLU DIROMBAK, BUKAN SEKADAR DIPERCANTIK

Untuk aplikasi POS, kecepatan adalah prioritas.

Flow kasir ideal:

```text
POS
 ↓
Scan barcode
 ↓
Barang masuk
 ↓
Qty
 ↓
Customer optional
 ↓
Total
 ↓
Bayar
 ↓
Kembalian
 ↓
Selesai
```

Jangan membuat kasir terlalu sering berpindah halaman.

Saya akan membuat POS menjadi:

> **satu layar transaksi utama dengan keyboard/scanner-first interaction.**

---

# 28. 🟡 EMPTY STATE DAN ERROR STATE HARUS LEBIH PROFESIONAL

Aplikasi bisnis membutuhkan kondisi seperti:

```text
Belum ada produk
Belum ada transaksi
Stok kosong
Tidak ada pelanggan
Tidak ada piutang
Tidak ada pengeluaran
Internet terputus
Firebase error
Printer tidak terhubung
Backup gagal
```

Jangan hanya:

```text
Error: something went wrong
```

Harus menjelaskan:

```text
Apa yang terjadi
Mengapa
Apa yang bisa dilakukan user
```

---

# 29. 🟡 OFFLINE MODE BELUM DIDEFINISIKAN SECARA BISNIS

Firestore memang mendukung persistence dan aplikasi mengaktifkannya.

Tetapi:

> offline cache ≠ offline POS architecture.

Harus jelas:

```text
Offline:
scan barang       YES
lihat produk      YES
buat transaksi    ?
update stok       ?
payment           ?
shift             ?
```

Kemudian ketika online:

```text
sync
conflict detection
retry
idempotency
```

harus ditentukan.

---

# 30. 🟡 BELUM ADA IDEMPOTENCY TRANSACTION

Ini penting jika koneksi buruk.

Contoh:

```text
Kasir klik BAYAR
        ↓
request dikirim
        ↓
internet timeout
        ↓
kasir klik lagi
```

Jika tidak ada idempotency:

```text
TRX-001
TRX-002
```

bisa tercipta dua transaksi.

Sistem perlu:

```text
clientTransactionId
```

yang unik dan hanya boleh diproses sekali.

---

# 31. 🟡 VALIDASI HARUS DIPERKUAT DI SEMUA FORM

Misalnya produk:

```text
nama kosong
harga -100
stok -5
minimum stock -2
barcode duplicate
```

harus ditolak.

Pelanggan:

```text
nomor HP invalid
```

Pengeluaran:

```text
amount <= 0
```

Pembayaran:

```text
amount > remaining
```

Semua perlu validasi yang konsisten.

---

# 32. 🟡 BELUM ADA STRATEGI INDEX FIRESTORE YANG JELAS

Karena aplikasi menggunakan banyak:

```text
where
orderBy
```

dan query berdasarkan berbagai field, index Firestore harus dirancang sejak awal.

Terutama untuk:

```text
sales
customer
cashier
date
paymentStatus
shifts
stock movement
expenses
audit logs
```

Jangan menunggu production lalu baru menemukan query gagal karena missing index.

---

# 33. 🟡 TESTING MASIH PERLU DIPERKUAT

Di repository memang sudah ada folder:

```text
test
```

dan dependency seperti:

```text
mockito
fake_cloud_firestore
build_runner
```

tersedia. ([GitHub][1])

Ini bagus.

Tetapi aplikasi POS membutuhkan testing yang jauh lebih agresif.

Minimal:

### Unit test

```text
total calculation
payment calculation
change calculation
debt calculation
stock calculation
profit calculation
```

### Integration test

```text
create sale
update stock
payment
debt
shift
refund
```

### Security test

```text
kasir mencoba delete product
kasir mencoba ubah price
kasir mencoba akses user
anonymous mencoba Firestore
```

---

# 34. 🟡 BELUM ADA CI/CD QUALITY GATE

Repository menunjukkan GitHub Actions tersedia sebagai fitur GitHub, tetapi dari struktur yang terlihat tidak tampak pipeline CI/CD yang jelas untuk memastikan kualitas setiap perubahan. ([GitHub][1])

Idealnya setiap push:

```text
flutter analyze
↓
flutter test
↓
format check
↓
security checks
↓
build APK
```

baru boleh merge.

---

# 35. 🟡 `ignore_for_file` TERLALU AGRESIF

Banyak file diawali dengan:

```dart
// ignore_for_file:
```

yang mematikan beberapa warning/lint sekaligus.

Contohnya:

```text
avoid_print
deprecated_member_use
constant_identifier_names
...
```

Ini bukan bug langsung.

Tetapi secara engineering:

> warning yang terlalu banyak disembunyikan membuat technical debt sulit terlihat.

Lebih baik memperbaiki warning satu per satu daripada mematikannya secara global pada file.

---

# 36. 🟡 ERROR HANDLING MASIH TERLALU GENERIK

Beberapa service menggunakan:

```dart
catch (e)
```

kemudian:

```text
Get.snackbar("Error", ...)
```

Ini bagus untuk UX dasar, tetapi production membutuhkan klasifikasi:

```text
NetworkError
PermissionDenied
ValidationError
ConflictError
FirestoreError
PrinterError
AuthenticationError
```

sehingga UI bisa memberikan tindakan yang tepat.

---

# 37. 🟡 OBSERVABILITY BELUM MATANG

Crashlytics sudah digunakan di `main.dart`, ini merupakan poin positif.

Namun aplikasi bisnis sebaiknya juga mempunyai metrik seperti:

```text
checkout_success
checkout_failed
payment_failed
stock_conflict
printer_failed
sync_failed
backup_failed
login_failed
```

Supaya masalah operasional bisa diketahui sebelum pengguna mengeluh.

---

# 38. 🟡 PRINTER HARUS MEMILIKI FALLBACK

Ada:

```text
blue_thermal_printer
```

di dependencies.

Tetapi POS tidak boleh bergantung penuh pada printer.

Jika printer gagal:

```text
Transaksi tetap sukses
        ↓
Tampilkan struk digital
        ↓
Retry print
```

bukan:

```text
printer gagal
↓
transaksi dianggap gagal
```

---

# 39. 🟡 DATA CUSTOMER PERLU PRIVACY CONTROL

Data pelanggan mencakup:

```text
nama
nomor HP
alamat
```

yang sudah didefinisikan dalam PRD. ([GitHub][3])

Karena itu perlu:

- akses berbasis role;
- minimal data exposure;
- audit;
- backup protection;
- tidak sembarang menampilkan nomor HP;
- aturan retention.

Dengan Firestore rule saat ini, data tersebut justru terbuka secara global.

---

# 40. 🟢 REPOSITORY DAN DOKUMENTASI MASIH TERLALU "DEFAULT FLUTTER"

README repository masih berbunyi:

> "A new Flutter project."

dan deskripsinya belum menggambarkan aplikasi POS yang sebenarnya. ([GitHub][1])

Padahal PRD sudah cukup lengkap.

README seharusnya berisi:

```text
Fathiyah Store
↓
POS & Store Management

Features
Architecture
Tech stack
Firebase setup
Environment
Firestore structure
Roles
Development
Testing
Deployment
Security
Backup
```

---

# 41. 🟢 NAMING MASIH PERLU DIBERSIHKAN

Ada beberapa ketidakkonsistenan seperti:

```text
Fathiyah Store
Fathiyah Stort
fathiyah_store
```

PRD sendiri menggunakan "Fathiyah Stort" di beberapa bagian. ([GitHub][3])

Sebaiknya tetapkan satu brand resmi:

> **Fathiyah Store**

Kemudian konsisten di:

- application title;
- package;
- README;
- PRD;
- receipt;
- Firebase;
- UI;
- documentation.

---

# Prioritas Perombakan

Kalau saya yang mengambil alih project ini, **saya tidak akan langsung menambahkan fitur baru**.

Saya akan mengerjakan dalam urutan berikut:

### 🔴 PHASE 1 — SECURITY

**Prioritas 1**

```text
Firebase Authentication
        ↓
UID
        ↓
Role
        ↓
Firestore Security Rules
        ↓
Permission
```

Hapus:

```text
password plaintext
admin / 123
allow read, write: if true
```

Ini mutlak.

---

### 🔴 PHASE 2 — DATA INTEGRITY

**Prioritas 2**

Rombak transaksi menjadi:

```text
Sale
SaleItem
Payment
StockMovement
CashMovement
Shift
AuditLog
```

Kemudian gunakan:

```text
Firestore Transaction
Batch
Atomic operations
Idempotency
```

---

### 🔴 PHASE 3 — MONEY ENGINE

**Prioritas 3**

Ubah:

```text
double
```

menjadi integer money representation.

Bangun satu `Money/Financial Calculation Layer` agar:

```text
subtotal
discount
tax
payment
change
debt
profit
cash
```

tidak dihitung berbeda-beda di berbagai halaman.

---

### 🔴 PHASE 4 — STOCK ENGINE

**Prioritas 4**

Jadikan stock movement sebagai sumber kebenaran:

```text
PURCHASE
SALE
RETURN
DAMAGE
LOSS
ADJUSTMENT
```

dan pastikan:

```text
stock = calculated/validated balance
```

bukan angka yang bebas dimodifikasi.

---

### 🔴 PHASE 5 — POS ENGINE

**Prioritas 5**

Rombak checkout:

```text
Scan
↓
Cart
↓
Customer
↓
Payment
↓
Change
↓
Receipt
```

dengan dukungan:

- barcode;
- keyboard;
- cash;
- transfer;
- QRIS;
- split payment jika dibutuhkan;
- partial payment;
- debt;
- refund;
- void.

---

### 🟠 PHASE 6 — SHIFT & CASH MANAGEMENT

**Prioritas 6**

Buat:

```text
Open Shift
↓
Cash Sales
↓
Debt Payments
↓
Cash Expenses
↓
Other Cash Movement
↓
Close Shift
↓
Expected Cash
↓
Actual Cash
↓
Difference
```

Ini akan membuat aplikasi jauh lebih profesional.

---

### 🟠 PHASE 7 — BACKUP & RECOVERY

**Prioritas 7**

Jangan hanya CSV.

Buat:

```text
Export
Backup
Restore
Validation
Preview
Conflict detection
Audit
Rollback
```

---

### 🟠 PHASE 8 — PERFORMANCE

**Prioritas 8**

Hentikan pola:

```text
load all sales
load all customers
load all products
```

Gunakan:

```text
pagination
lazy loading
query filtering
aggregation
indexes
```

---

### 🟡 PHASE 9 — UI/UX

**Prioritas 9**

Baru setelah engine aman, rombak UI.

Fokus terbesar:

```text
POS screen
Dashboard
Product management
Debt management
Shift
Reports
```

Jangan sekadar membuatnya "lebih cantik".

Targetnya:

> **kasir bisa menyelesaikan transaksi dengan sesedikit mungkin tap.**

---

### 🟡 PHASE 10 — TESTING & CI/CD

**Prioritas 10**

Buat automated test untuk:

```text
Sale
Payment
Debt
Stock
Shift
Refund
Permission
Security
```

dan CI:

```text
analyze
↓
format
↓
test
↓
build
```
