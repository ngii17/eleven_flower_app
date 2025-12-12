import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cart.dart';
import '../providers/auth_provider.dart';
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
  Cart? _cartData; 

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    try {
      final cart = await Provider.of<AuthProvider>(context, listen: false).getCart();
      setState(() {
        _cartData = cart;
      });
    } catch (e) {
      debugPrint("Gagal load cart di checkout: $e");
    }
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(price);
  }

  void _showDialog(String title, String content, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          // Menggunakan Color manual agar tidak error const
          style: TextStyle(color: isError ? Colors.red : const Color(0xFF388E3C)), 
        ),
        content: Text(content),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF06292), 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _processCheckout() async {
    if (_namaController.text.trim().isEmpty ||
        _hpController.text.trim().isEmpty ||
        _alamatController.text.trim().isEmpty ||
        _selectedDate == null) {
      _showDialog("Data Kurang", "Mohon lengkapi Nama, No HP, Alamat, dan Tanggal Pengiriman.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.checkout(
        namaPenerima: _namaController.text.trim(),
        noHpPenerima: _hpController.text.trim(),
        alamatPengiriman: _alamatController.text.trim(),
        tanggalPengiriman: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        catatan: _ucapanController.text.trim().isEmpty ? null : _ucapanController.text.trim(),
      );

      final String waUrl = result['payment_url'] ?? result['wa_url'] ?? '';

      if (waUrl.isNotEmpty && await canLaunchUrl(Uri.parse(waUrl))) {
        await launchUrl(Uri.parse(waUrl), mode: LaunchMode.externalApplication);
        
        if (mounted) Navigator.pop(context, true); 
      } else {
        throw "Tidak bisa membuka WhatsApp. Link error.";
      }
    } catch (e) {
      String msg = e.toString().replaceAll("Exception:", "").trim();
      _showDialog("Gagal Checkout", msg, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7), // Background Pink Muda
      appBar: AppBar(
        title: const Text("Checkout Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFE6CACE), 
        foregroundColor: const Color(0xFF3E2723), 
        elevation: 0,
      ),
      body: _cartData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 1. RINGKASAN PESANAN ---
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cartData!.items.length,
                    itemBuilder: (context, index) {
                      final item = _cartData!.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Produk
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                '${ApiService.baseStorageUrl}${item.image}',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80, 
                                  height: 80, 
                                  color: const Color(0xFFEEEEEE), 
                                  child: const Icon(Icons.local_florist, color: Colors.pink)
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            
                            // Info Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${item.quantity} x ${formatRupiah(item.price)}",
                                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formatRupiah(item.price * item.quantity),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Header Kecil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Lengkapi Data Pengiriman",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 2. FORM INPUT ---
                  
                  const Text("NAMA:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  _buildPinkTextField(controller: _namaController, hint: "Nama Penerima", icon: Icons.person_outline),
                  
                  const SizedBox(height: 15),

                  const Text("NOMOR TELEPON:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  _buildPinkTextField(controller: _hpController, hint: "08xxxxx", icon: Icons.phone_android, isNumber: true),

                  const SizedBox(height: 15),

                  const Text("ALAMAT:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  _buildPinkTextField(controller: _alamatController, hint: "Alamat Lengkap...", icon: Icons.location_on_outlined, maxLines: 3),

                  const SizedBox(height: 15),

                  const Text("TANGGAL PENGIRIMAN:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE4EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black54, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate == null ? "Pilih Tanggal" : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                            style: TextStyle(color: _selectedDate == null ? Colors.black45 : Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 3. KARTU UCAPAN ---
                  const Text("KARTU UCAPAN:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE4EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.card_giftcard, color: Colors.black87),
                            SizedBox(width: 10),
                            Text("Kartu Ucapan (Opsional)", style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _ucapanController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Tulis ucapan manis di sini...\nContoh: "Happy Birthday Sayang!"',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 4. TOMBOL LANJUTKAN ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _processCheckout,
                      // PERBAIKAN: Menggunakan Icons.chat karena Icons.whatsapp tidak ada di material
                      icon: const Icon(Icons.chat, color: Colors.white), 
                      label: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("LANJUTKAN KE WHATSAPP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE58CB0), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildPinkTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE4EB), 
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black54, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
        ),
      ),
    );
  }
}