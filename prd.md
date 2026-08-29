Tentu. Berdasarkan konsep yang sudah kita sepakati, saya sarankan **Fathiyah Stort** dibangun sebagai aplikasi **POS + Manajemen Stok + Pengeluaran + Piutang VIP + Multi-Kasir**. Berikut PRD yang bisa langsung dijadikan acuan pengembangan Flutter + Firebase.

# PRD — Fathiyah Stort

**Product Name:** Fathiyah Store
**Platform:** Android
**Framework:** Flutter + Dart
**Backend:** Firebase
**Database:** Cloud Firestore
**Authentication:** Firebase Authentication
**Storage:** Firebase Storage
**Push Notification:** Firebase Cloud Messaging
**State Management:** GetX
**Target:** Pemilik toko, admin, dan kasir

---

# 1. Gambaran Produk

**Fathiyah Stort** adalah aplikasi Android untuk membantu toko mengelola:

- Produk dan stok
- Penjualan
- Pelanggan
- Pelanggan VIP
- Pembayaran dan piutang
- Pengeluaran
- Kasir/multi-user
- Laporan harian, mingguan, bulanan, dan tahunan
- Keuangan sederhana
- Riwayat aktivitas pengguna

Fitur pembeda utama Fathiyah Stort adalah **sistem pelanggan VIP**.

Pelanggan VIP **tidak mendapatkan diskon atau harga lebih murah**.

VIP hanya mendapatkan fasilitas:

> **Boleh membayar sebagian dari total transaksi, sedangkan sisa pembayaran dicatat sebagai piutang sampai lunas.**

Pelanggan dapat diubah dari **Umum → VIP** atau **VIP → Umum** kapan saja oleh pengguna yang memiliki izin.

---

# 2. Tujuan Aplikasi

### Tujuan utama

Membuat pengelolaan toko menjadi:

- Lebih cepat
- Lebih mudah
- Terorganisir
- Transparan
- Mengurangi kesalahan pencatatan
- Memudahkan kontrol stok
- Memudahkan mengetahui uang masuk dan pengeluaran
- Memudahkan mengontrol piutang pelanggan VIP

### Prinsip desain

> **Sederhana digunakan kasir, lengkap untuk admin, dan informatif untuk pemilik.**

---

# 3. Target Pengguna

## A. Owner

Pemilik toko.

Memiliki akses penuh terhadap seluruh sistem.

## B. Admin

Mengelola operasional toko dan pengguna.

## C. Kasir

Fokus pada transaksi penjualan dan pelanggan.

Jumlah kasir **tidak dibatasi satu orang**.

Admin dapat menambahkan beberapa akun kasir.

Contoh:

```text
Owner
│
├── Admin
│
├── Kasir 1
├── Kasir 2
├── Kasir 3
└── Kasir 4
```

---

# 4. Role & Permission

Sistem menggunakan **Role-Based Access Control**.

### Owner

Akses penuh:

- Dashboard
- Produk
- Stok
- Penjualan
- Pelanggan
- VIP
- Piutang
- Pengeluaran
- Laporan
- Pengguna
- Role & Permission
- Pengaturan
- Audit Log

### Admin

Akses hampir penuh sesuai permission yang diberikan Owner.

### Kasir

Default:

- Dashboard
- Membuat transaksi
- Melihat produk
- Melihat stok
- Menambah pelanggan
- Mengubah status VIP jika diberi izin
- Menerima pembayaran
- Melihat transaksi sendiri

Tidak boleh:

- Menghapus produk
- Mengubah harga
- Mengelola pengguna
- Mengubah pengaturan sistem
- Menghapus transaksi

Permission dapat disesuaikan oleh administrator.

---

# 5. Dashboard

Dashboard adalah halaman utama.

Menampilkan:

### Ringkasan hari ini

```text
Penjualan
Rp2.500.000

Uang Masuk
Rp2.200.000

Pengeluaran
Rp500.000

Piutang
Rp300.000
```

### Informasi tambahan

- Jumlah transaksi
- Laba
- Produk stok menipis
- Produk habis
- Piutang VIP
- Transaksi terbaru
- Aktivitas kasir

### Grafik

Filter:

- Hari
- Minggu
- Bulan
- Tahun

Grafik:

- Penjualan
- Pengeluaran
- Laba
- Uang masuk
- Piutang

---

# 6. Manajemen Produk

Admin dapat:

- Tambah produk
- Edit produk
- Nonaktifkan produk
- Hapus produk dengan permission
- Tambah kategori
- Atur satuan
- Atur harga beli
- Atur harga jual
- Atur stok
- Atur stok minimum
- Menambahkan barcode

Data produk:

```text
ID Produk
Nama
Kategori
Barcode
Satuan
Harga Beli
Harga Jual
Stok
Stok Minimum
Status
Foto
Created At
Updated At
```

---

# 7. Manajemen Stok

Stok tidak hanya berupa angka.

Sistem mencatat **pergerakan stok**.

Contoh:

```text
Kopi

Stok awal       100
Stok masuk      +50
Penjualan       -30
Barang rusak    -5
Stok sekarang   115
```

Jenis pergerakan:

- Stok awal
- Pembelian
- Penjualan
- Barang rusak
- Barang hilang
- Koreksi stok
- Retur

Setiap perubahan harus menyimpan:

```text
Produk
Jumlah
Jenis aktivitas
User
Waktu
Catatan
```

---

# 8. Stok Minimum

Setiap produk dapat memiliki batas minimum.

Contoh:

```text
Kopi
Stok: 5
Minimum: 10
```

Sistem memberikan peringatan:

> ⚠️ Stok Kopi hampir habis.

Jika stok:

```text
0
```

maka:

> 🔴 Stok habis.

---

# 9. Pelanggan

Data pelanggan:

```text
ID
Nama
Nomor HP
Alamat
Tipe Pelanggan
Catatan
Status
Created At
```

Tipe:

```text
👤 Umum
⭐ VIP
```

Pelanggan dapat diubah:

```text
Umum → VIP
VIP → Umum
```

Perubahan status **tidak mengubah transaksi lama**.

---

# 10. Sistem VIP

### Definisi VIP

VIP **bukan diskon**.

VIP **bukan harga khusus**.

VIP **tidak mempunyai masa berlaku**.

VIP hanya memiliki hak:

> **Dapat melakukan pembayaran sebagian dan memiliki sisa pembayaran/piutang.**

Contoh:

```text
Total transaksi
Rp100.000

Bayar
Rp50.000

Sisa
Rp50.000

Status
🟡 Sebagian
```

---

# 11. Transaksi Pelanggan Umum

Pelanggan umum secara default harus melunasi transaksi.

Contoh:

```text
Total
Rp100.000

Bayar
Rp100.000

Sisa
Rp0

🟢 LUNAS
```

Jika permission khusus diberikan, sistem dapat dibuat lebih fleksibel, tetapi default-nya **pelanggan umum tidak memiliki fasilitas piutang VIP**.

---

# 12. Transaksi VIP

Flow:

```text
Pilih pelanggan
       ↓
Ahmad ⭐ VIP
       ↓
Pilih barang
       ↓
Total Rp100.000
       ↓
Masukkan pembayaran
       ↓
Rp50.000
       ↓
Sisa Rp50.000
       ↓
🟡 BELUM LUNAS
```

Sistem otomatis mencatat piutang.

---

# 13. Status Pembayaran

Sistem memiliki tiga status utama:

### 🟢 Lunas

```text
Total = pembayaran
Sisa = 0
```

### 🟡 Sebagian

```text
Total > pembayaran
Sisa > 0
```

### 🔴 Belum Dibayar

```text
Total > 0
Pembayaran = 0
```

---

# 14. Pembayaran Piutang

Pelanggan VIP dapat membayar sisa transaksi kapan saja.

Contoh:

```text
Ahmad ⭐

Piutang:
Rp250.000
```

Klik:

**Bayar Piutang**

Kemudian:

```text
Jumlah pembayaran
Rp100.000

Sisa:
Rp150.000
```

Status:

```text
🟡 SEBAGIAN
```

Pembayaran berikutnya:

```text
Rp150.000
```

Maka:

```text
🟢 LUNAS
```

---

# 15. Riwayat Pembayaran

Setiap pembayaran disimpan.

Contoh:

```text
TRX-001

Total        Rp100.000

Pembayaran:
29 Agustus   Rp50.000
02 September Rp50.000

Total Bayar  Rp100.000
Sisa         Rp0

🟢 LUNAS
```

---

# 16. Halaman Piutang

Menampilkan semua pelanggan yang masih memiliki sisa pembayaran.

```text
PIUTANG

Ahmad ⭐
Rp250.000

Budi ⭐
Rp150.000

Siti ⭐
Rp100.000
```

Filter:

- Semua
- VIP
- Jatuh tempo\* (opsional)
- Piutang terbesar
- Terbaru

> Catatan: karena VIP tidak memiliki jangka waktu, **jatuh tempo bukan fitur wajib**. Bisa ditambahkan kemudian jika bisnis membutuhkannya.

---

# 17. Penjualan

Fitur:

- Cari produk
- Scan barcode
- Tambahkan ke keranjang
- Ubah jumlah
- Hapus item
- Pilih pelanggan
- Hitung total otomatis
- Input pembayaran
- Pilih metode pembayaran
- Simpan transaksi
- Cetak/bagikan struk

Metode pembayaran:

```text
Cash
Transfer
QRIS
E-Wallet
Lainnya
```

---

# 18. Struk

Setelah transaksi berhasil:

```text
FATHIYAH STORT
──────────────────

TRX-20260829-001

Pelanggan:
Ahmad ⭐ VIP

Kopi       2 × 10.000
Air        2 ×  5.000

Total       Rp30.000
Dibayar     Rp15.000
Sisa        Rp15.000

🟡 BELUM LUNAS

Kasir:
Fulan

Terima kasih
```

Struk dapat:

- Disimpan sebagai PDF
- Dibagikan
- Dicetak

---

# 19. Pengeluaran

Admin/kasir yang memiliki permission dapat mencatat pengeluaran.

Contoh kategori:

```text
Pembelian Barang
Transportasi
Listrik
Internet
Gaji
Perawatan
Operasional
Lainnya
```

Data:

```text
Kategori
Nominal
Metode pembayaran
Catatan
Tanggal
User
```

---

# 20. Laporan

### Laporan Penjualan

Filter:

```text
Hari ini
Kemarin
Minggu
Bulan
Tahun
Custom
```

Menampilkan:

```text
Total transaksi
Total penjualan
Total pembayaran
Total piutang
```

---

# 21. Laporan Pengeluaran

Contoh:

```text
PENGELUARAN AGUSTUS

Pembelian barang    Rp5.000.000
Gaji                Rp2.000.000
Listrik             Rp  300.000
Transportasi        Rp  200.000

TOTAL               Rp7.500.000
```

---

# 22. Laporan Laba

Sistem membedakan:

```text
Omzet
HPP
Laba Kotor
Pengeluaran
Laba Bersih
```

Contoh:

```text
Omzet        Rp10.000.000
HPP           Rp6.000.000
────────────────────────
Laba Kotor    Rp4.000.000

Pengeluaran   Rp1.500.000
────────────────────────
Laba Bersih   Rp2.500.000
```

---

# 23. Perbedaan Omzet dan Uang Masuk

Sistem **wajib** membedakan keduanya.

Contoh:

```text
Penjualan       Rp1.000.000
Sudah dibayar   Rp  700.000
Piutang         Rp  300.000
```

Maka:

**Omzet = Rp1.000.000**

**Uang masuk = Rp700.000**

**Piutang = Rp300.000**

Ketika piutang dibayar minggu berikutnya, uang masuk bertambah tetapi omzet transaksi lama **tidak dihitung ulang**.

---

# 24. Multi-User

Admin dapat:

- Tambah user
- Edit user
- Nonaktifkan user
- Aktifkan user
- Atur role
- Atur permission
- Reset akses

Contoh:

```text
PENGGUNA

Mustofa
Owner
● Aktif

Ahmad
Admin
● Aktif

Fulan
Kasir
● Aktif

Budi
Kasir
○ Nonaktif
```

---

# 25. Identitas Kasir

Setiap transaksi wajib mencatat:

```text
cashierId
cashierName
createdAt
```

Contoh:

```text
TRX-001

Kasir:
Fulan

29 Agustus 2026
10:30
```

Sehingga transaksi dapat ditelusuri.

---

# 26. Shift Kasir

Untuk tahap profesional, tambahkan:

### Buka Shift

```text
Kasir:
Fulan

Modal awal:
Rp500.000

Mulai:
08:00
```

### Tutup Shift

```text
Modal awal          Rp500.000
Penjualan Cash      Rp1.500.000
Pengeluaran Cash    Rp100.000
────────────────────────────
Seharusnya           Rp1.900.000

Uang aktual          Rp1.890.000

Selisih              -Rp10.000
```

---

# 27. Audit Log

Sistem mencatat aktivitas penting.

Contoh:

```text
29 Aug 10:20
Fulan membuat transaksi TRX-001

29 Aug 11:10
Admin mengubah status Ahmad
Umum → VIP

29 Aug 11:30
Admin mengubah stok Kopi
50 → 40
```

Audit log tidak boleh mudah dihapus oleh kasir.

---

# 28. Notifikasi

Notifikasi dapat digunakan untuk:

- Stok hampir habis
- Stok habis
- Transaksi berhasil
- Pembayaran piutang
- Aktivitas penting
- User baru
- Perubahan status pelanggan

---

# 29. Pencarian

Pencarian harus tersedia pada:

- Produk
- Pelanggan
- Transaksi
- Piutang
- Pengeluaran
- User

---

# 30. UI/UX

Target desain:

**Modern, bersih, sederhana, dan mudah dipahami.**

### Bottom Navigation

```text
🏠 Home
📦 Produk
🛒 Transaksi
📊 Laporan
⚙️ Pengaturan
```

Untuk kasir:

```text
🏠
🛒
👥
💳
```

Tidak perlu menampilkan menu yang tidak memiliki permission.

---

# 31. Prinsip UI

Gunakan:

- Card
- Rounded corner
- Icon yang jelas
- Typography sederhana
- Empty state
- Loading state
- Error state
- Confirmation dialog
- Search bar
- Filter
- Bottom sheet
- Floating action button bila diperlukan

Hindari dashboard yang terlalu penuh.

---

# 32. Firebase Architecture

```text
Flutter
   │
   ├── Firebase Authentication
   │
   ├── Cloud Firestore
   │
   ├── Firebase Storage
   │
   └── Firebase Cloud Messaging
```

Firestore:

```text
users
shops
products
categories
customers
sales
sale_items
payments
expenses
expense_categories
stock_movements
shifts
audit_logs
settings
notifications
```

---

# 33. Struktur Data Utama

### Users

```text
users/{userId}

name
email
role
permissions
status
shopId
createdAt
updatedAt
```

### Customers

```text
customers/{customerId}

name
phone
address
type
status
createdAt
updatedAt
```

`type`:

```text
general
vip
```

### Products

```text
products/{productId}

name
categoryId
barcode
unit
purchasePrice
sellingPrice
stock
minimumStock
imageUrl
status
createdAt
updatedAt
```

### Sales

```text
sales/{saleId}

customerId
customerType
cashierId
subtotal
totalAmount
paidAmount
remainingAmount
paymentStatus
paymentMethod
createdAt
updatedAt
```

### Payments

```text
payments/{paymentId}

saleId
customerId
amount
paymentMethod
cashierId
createdAt
```

---

# 34. Aturan Penting Sistem

### Rule 1

Harga barang **tidak berubah berdasarkan VIP**.

### Rule 2

VIP hanya memberikan fasilitas **pembayaran sebagian**.

### Rule 3

Transaksi lama tidak berubah ketika status pelanggan berubah.

### Rule 4

Harga transaksi disimpan saat transaksi dilakukan.

### Rule 5

Pembayaran tambahan dicatat sebagai transaksi pembayaran tersendiri.

### Rule 6

Stok berkurang berdasarkan barang yang benar-benar terjual.

### Rule 7

Omzet tidak sama dengan uang yang diterima.

### Rule 8

Piutang harus dihitung berdasarkan:

```text
Total transaksi - seluruh pembayaran
```

### Rule 9

Setiap transaksi memiliki identitas kasir.

### Rule 10

Penghapusan data penting harus dibatasi dengan permission.

---

# 35. Roadmap Pengembangan

## Phase 1 — Foundation

- Setup Flutter
- Firebase
- Authentication
- Struktur database
- Theme
- Routing
- GetX
- Role dasar

## Phase 2 — Produk & Stok

- Produk
- Kategori
- Stok
- Stock movement
- Stok minimum
- Barcode

## Phase 3 — Pelanggan & VIP

- Pelanggan
- Status Umum/VIP
- Ubah status
- Riwayat pelanggan

## Phase 4 — Penjualan

- Keranjang
- Transaksi
- Pembayaran
- Status lunas/sebagian
- Struk
- Riwayat transaksi

## Phase 5 — Piutang

- Daftar piutang
- Detail piutang
- Pembayaran cicilan
- Riwayat pembayaran
- Status pelunasan

## Phase 6 — Pengeluaran & Keuangan

- Pengeluaran
- Kategori
- HPP
- Omzet
- Laba kotor
- Laba bersih

## Phase 7 — Multi-User

- User management
- Role
- Permission
- Kasir
- Shift
- Audit log

## Phase 8 — Dashboard & Reporting

- Dashboard
- Grafik
- Laporan harian
- Mingguan
- Bulanan
- Tahunan
- Export PDF
- Export CSV/Excel

## Phase 9 — Professional Features

- Notifikasi
- Backup
- Barcode scanner
- Printer
- Share WhatsApp
- Advanced analytics
- Pengaturan toko

---

# 36. MVP

Untuk versi pertama, **jangan langsung membuat semuanya**.

MVP Fathiyah Stort sebaiknya hanya:

```text
🔐 Login
    ↓
🏠 Dashboard
    ↓
📦 Produk & Stok
    ↓
👥 Pelanggan
    ↓
⭐ VIP
    ↓
🛒 Penjualan
    ↓
💳 Pembayaran
    ↓
📒 Piutang
    ↓
💰 Pengeluaran
    ↓
📊 Laporan
    ↓
⚙️ Pengaturan
```

Setelah alur ini benar-benar stabil, baru tambahkan barcode, printer, shift, audit log, export, dan fitur lanjutan.
