import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodel/ramadhan_view_model.dart';

class RamadhanInfakPage extends StatefulWidget {
  const RamadhanInfakPage({super.key});

  @override
  State<RamadhanInfakPage> createState() => _RamadhanInfakPageState();
}

class _RamadhanInfakPageState extends State<RamadhanInfakPage> {
  final _nominalController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _catatanController = TextEditingController();

  // Daftar nominal cepat untuk memudahkan user
  final List<int> _quickNominals = [2000, 5000, 10000, 20000, 50000, 100000];

  @override
  void dispose() {
    _nominalController.dispose();
    _kategoriController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7C5ABF);
    const deepPurple = Color(0xFF2A0E5A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Consumer<RamadhanViewModel>(
        builder: (context, vm, child) {
          final infakList = vm.todayInfak;

          return Column(
            children: [
              // --- CUSTOM HEADER ---
              _buildHeader(context, primaryColor),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FORM INPUT ---
                      _buildInputCard(context, vm, primaryColor),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: Row(
                          children: [
                            Icon(Icons.history_rounded, size: 20, color: Colors.black38),
                            SizedBox(width: 8),
                            Text(
                              'Riwayat Kebaikan Hari Ini',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),

                      // --- LIST RIWAYAT ---
                      infakList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: infakList.length,
                              itemBuilder: (context, index) {
                                final item = infakList[index];
                                return _buildInfakItem(index, item, vm, primaryColor);
                              },
                            ),
                      const SizedBox(height: 100), // Spasi agar tidak tertutup bottom bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // --- TOTAL BOTTOM BAR ---
      bottomSheet: Consumer<RamadhanViewModel>(
        builder: (context, vm, child) => _buildTotalBottomBar(vm.totalInfakHariIni, primaryColor),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primary) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Text(
              'Tabungan Infak',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, RamadhanViewModel vm, Color primary) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Nominal dengan Style Rupiah yang Besar
          TextField(
            controller: _nominalController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF2A0E5A)),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary),
              labelText: 'Jumlah Nominal',
              labelStyle: const TextStyle(fontSize: 14, color: Colors.black38),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary)),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Selection Nominal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickNominals.map((n) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(NumberFormat.compactCurrency(locale: 'id_ID', symbol: '').format(n)),
                    selected: false,
                    onSelected: (_) => setState(() => _nominalController.text = n.toString()),
                    backgroundColor: primary.withOpacity(0.05),
                    labelStyle: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Row Kategori & Catatan
          Row(
            children: [
              Expanded(
                child: _miniTextField(_kategoriController, 'Kategori', Icons.category_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniTextField(_catatanController, 'Catatan', Icons.edit_note_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              onPressed: () => _handleSave(vm),
              child: const Text(
                'Simpan Kebaikan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF7C5ABF)),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFF8F7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  void _handleSave(RamadhanViewModel vm) async {
    final nominalStr = _nominalController.text.trim();
    if (nominalStr.isEmpty) return;
    final nominal = int.tryParse(nominalStr);
    if (nominal == null || nominal <= 0) return;

    await vm.addInfak(
      nominal: nominal,
      kategori: _kategoriController.text.trim().isEmpty ? 'Umum' : _kategoriController.text.trim(),
      catatan: _catatanController.text.trim(),
    );

    _nominalController.clear();
    _kategoriController.clear();
    _catatanController.clear();
    FocusScope.of(context).unfocus();
  }

  Widget _buildInfakItem(int index, Map<String, dynamic> item, RamadhanViewModel vm, Color primary) {
    final nominal = item['nominal'] as int;
    final kategori = item['kategori'] as String? ?? 'Umum';
    final time = DateTime.parse(item['created_at'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0EDFF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.volunteer_activism_rounded, color: primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(nominal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2A0E5A)),
                ),
                Text(
                  kategori,
                  style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('HH:mm').format(time), style: const TextStyle(color: Colors.black26, fontSize: 11)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => vm.removeInfak(index),
                child: Icon(Icons.cancel_rounded, color: Colors.red[200], size: 20),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey[200]),
            const SizedBox(height: 16),
            const Text('Ayo mulai berbagi hari ini!', style: TextStyle(color: Colors.black26)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBottomBar(int total, Color primary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Terkumpul', style: TextStyle(color: Colors.black38, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary),
              ),
            ],
          ),
          Icon(Icons.verified_rounded, color: Colors.green[400], size: 32),
        ],
      ),
    );
  }
}