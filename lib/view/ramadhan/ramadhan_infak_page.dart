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

  @override
  void dispose() {
    _nominalController.dispose();
    _kategoriController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      appBar: AppBar(
        title: const Text('Catatan Infak', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A0E5A))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2A0E5A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RamadhanViewModel>(
        builder: (context, vm, child) {
          final infakList = vm.todayInfak;

          return Column(
            children: [
              // --- FORM INPUT CARD ---
              _buildInputCard(context, vm),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: Colors.black38),
                    SizedBox(width: 8),
                    Text('Riwayat Hari Ini', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38)),
                  ],
                ),
              ),

              // --- LIST RIWAYAT ---
              Expanded(
                child: infakList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: infakList.length,
                        itemBuilder: (context, index) {
                          final item = infakList[index];
                          final nominal = item['nominal'] as int;
                          final kategori = item['kategori'] as String? ?? 'Umum';
                          final catatan = item['catatan'] as String? ?? '-';
                          final createdAt = DateTime.parse(item['created_at'] as String);

                          return _buildInfakItem(index, nominal, kategori, catatan, createdAt, vm);
                        },
                      ),
              ),

              // --- TOTAL BOTTOM BAR ---
              _buildTotalBottomBar(vm.totalInfakHariIni),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, RamadhanViewModel vm) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5ABF).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nominalController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF7C5ABF)),
              labelText: 'Nominal Infak',
              hintText: 'Contoh: 50000',
              filled: true,
              fillColor: const Color(0xFFF8F7FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _kategoriController,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    filled: true,
                    fillColor: const Color(0xFFF8F7FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _catatanController,
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    filled: true,
                    fillColor: const Color(0xFFF8F7FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5ABF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () async {
                final nominalStr = _nominalController.text.trim();
                if (nominalStr.isEmpty) return;
                final nominal = int.tryParse(nominalStr);
                if (nominal == null || nominal <= 0) return;

                await vm.addInfak(
                  nominal: nominal,
                  kategori: _kategoriController.text.trim(),
                  catatan: _catatanController.text.trim(),
                );

                _nominalController.clear();
                _kategoriController.clear();
                _catatanController.clear();
                FocusScope.of(context).unfocus();
              },
              child: const Text('Simpan Kebaikan', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfakItem(int index, int nominal, String kategori, String catatan, DateTime time, RamadhanViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EDFF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3EFFF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.favorite_rounded, color: Color(0xFF7C5ABF), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rp ${NumberFormat('#,###', 'id_ID').format(nominal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2A0E5A))),
                Text('$kategori • $catatan', 
                  style: const TextStyle(color: Colors.black38, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('HH:mm').format(time), style: const TextStyle(color: Colors.black26, fontSize: 11)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => vm.removeInfak(index),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada infak hari ini', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTotalBottomBar(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Hari Ini', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Text('Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C5ABF))),
        ],
      ),
    );
  }
}