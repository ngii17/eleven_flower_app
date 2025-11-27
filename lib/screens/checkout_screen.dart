import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _ucapanController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  void _showDialog(String title, String content, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: isError ? Colors.red : Colors.green[700]),
        ),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _processCheckout() async {
    // Validasi wajib
    if (_namaController.text.trim().isEmpty ||
        _hpController.text.trim().isEmpty ||
        _alamatController.text.trim().isEmpty ||
        _selectedDate == null) {
      _showDialog("Data Kurang", "Mohon lengkapi semua field bertanda bintang (*)", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PANGGIL CHECKOUT DARI ApiService YANG SUDAH KITA FIX
      final result = await _apiService.checkout(
        namaPenerima: _namaController.text.trim(),
        noHpPenerima: _hpController.text.trim(),
        alamatPengiriman: _alamatController.text.trim(),
        tanggalPengiriman: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        catatan: _ucapanController.text.trim().isEmpty ? null : _ucapanController.text.trim(),
      );

      // Ambil link WhatsApp langsung dari Laravel (nomor admin + pesan lengkap)
      final String waUrl = result['payment_url'] ?? result['wa_url'] ?? '';

      if (waUrl.isEmpty) {
        throw "Link WhatsApp tidak ditemukan dari server";
      }

      if (await canLaunchUrl(Uri.parse(waUrl))) {
        await launchUrl(Uri.parse(waUrl), mode: LaunchMode.externalApplication);
      } else {
        throw "Tidak bisa membuka WhatsApp. Coba buka manual: $waUrl";
      }

      // Kosongkan keranjang setelah sukses
      await _apiService.clearCart();

      _showDialog(
        "Pesanan Berhasil!",
        "Terima kasih! Silakan lanjutkan pembayaran dan konfirmasi via WhatsApp ya",
      );

      // Kembali ke home
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }

    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains("Exception:")) {
        errorMsg = errorMsg.split("Exception:").last.trim();
      }
      _showDialog("Gagal Checkout", errorMsg, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout Pesanan"),
        backgroundColor: Colors.pink[100],
        foregroundColor: Colors.pink[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lengkapi Data Pengiriman",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const SizedBox(height: 20),

            // Nama Penerima
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: "Nama Penerima *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),

            // No HP
            TextField(
              controller: _hpController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "No HP Penerima *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 14),

            // Alamat
            TextField(
              controller: _alamatController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Alamat Lengkap *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 14),

            // Tanggal Pengiriman
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Tanggal Pengiriman *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Pilih tanggal pengiriman"
                      : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Ucapan Kartu
            TextField(
              controller: _ucapanController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Ucapan Kartu (Opsional)",
                hintText: "Contoh: Happy Anniversary sayangku...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.card_giftcard),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Checkout
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "LANJUTKAN KE WHATSAPP",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}