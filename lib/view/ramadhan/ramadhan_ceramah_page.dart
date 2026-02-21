import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodel/ramadhan_view_model.dart';

class RamadhanCeramahPage extends StatefulWidget {
  const RamadhanCeramahPage({super.key});

  @override
  State<RamadhanCeramahPage> createState() => _RamadhanCeramahPageState();
}

class _RamadhanCeramahPageState extends State<RamadhanCeramahPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<RamadhanViewModel>(context, listen: false).refreshTodayEntry();
  }

  final _temaController = TextEditingController();
  final _sumberController = TextEditingController();
  final _durasiController = TextEditingController();
  final _rangkumanController = TextEditingController();

  int? _editingIndex;

  @override
  void dispose() {
    _temaController.dispose();
    _sumberController.dispose();
    _durasiController.dispose();
    _rangkumanController.dispose();
    super.dispose();
  }

  void _handleSave(RamadhanViewModel vm) async {
    final tema = _temaController.text.trim();
    final sumber = _sumberController.text.trim();
    final durasiText = _durasiController.text.trim();
    final rangkuman = _rangkumanController.text.trim();

    if (tema.isEmpty || sumber.isEmpty || durasiText.isEmpty || rangkuman.isEmpty) {
      _showSnackBar('Semua kolom wajib diisi!', Colors.orange);
      return;
    }

    final durasi = int.tryParse(durasiText);
    if (durasi == null || durasi <= 0) {
      _showSnackBar('Durasi harus angka positif', Colors.redAccent);
      return;
    }

    if (_editingIndex != null) {
      await vm.editCeramah(
        index: _editingIndex!,
        tema: tema,
        sumber: sumber,
        durasiMenit: durasi,
        rangkuman: rangkuman,
      );
      setState(() => _editingIndex = null);
    } else {
      await vm.addCeramah(
        tema: tema,
        sumber: sumber,
        durasiMenit: durasi,
        rangkuman: rangkuman,
      );
    }

    _clearForm();
    _showSnackBar(_editingIndex != null ? 'Catatan diperbarui' : 'Berhasil disimpan', Colors.green);
  }

  void _clearForm() {
    _temaController.clear();
    _sumberController.clear();
    _durasiController.clear();
    _rangkumanController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _startEditing(int index, Map<String, dynamic> item) {
    setState(() {
      _editingIndex = index;
      _temaController.text = item['tema'] ?? '';
      _sumberController.text = item['sumber'] ?? '';
      _durasiController.text = (item['durasi'] ?? '').toString();
      _rangkumanController.text = item['rangkuman'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7C5ABF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Consumer<RamadhanViewModel>(
        builder: (context, vm, child) {
          final ceramahList = vm.todayCeramah;

          return Column(
            children: [
              // --- CUSTOM HEADER ---
              _buildHeader(context, primaryColor),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildInputSection(context, vm, primaryColor),
                      const SizedBox(height: 32),
                      _buildListHeader(ceramahList.length),
                      const SizedBox(height: 16),
                      ceramahList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: ceramahList.length,
                              itemBuilder: (context, index) {
                                return _buildCeramahCard(index, ceramahList[index], vm, primaryColor);
                              },
                            ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primary) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 25, left: 20, right: 20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Catatan Ceramah',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48), // Spacer balance
            ],
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, RamadhanViewModel vm, Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _customTextField(_temaController, 'Tema Ceramah', Icons.mic_none_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _customTextField(_sumberController, 'Ustadz', Icons.person_outline_rounded)),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: _customTextField(_durasiController, 'Menit', Icons.timer_outlined, isNumber: true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _customTextField(_rangkumanController, 'Rangkuman Materi...', Icons.edit_note_rounded, maxLines: 3),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _handleSave(vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(
                _editingIndex != null ? 'Simpan Perubahan' : 'Catat Sekarang',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          if (_editingIndex != null)
            TextButton(
              onPressed: () => setState(() => _editingIndex = null),
              child: const Text('Batal Edit', style: TextStyle(color: Colors.grey)),
            )
        ],
      ),
    );
  }

  Widget _customTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF7C5ABF), size: 20),
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: const Color(0xFFF8F7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildListHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Catatan Hari Ini',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2A0E5A)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF7C5ABF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('$count Catatan', style: const TextStyle(color: Color(0xFF7C5ABF), fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildCeramahCard(int index, Map<String, dynamic> item, RamadhanViewModel vm, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EDFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.book_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['tema'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2A0E5A))),
                    const SizedBox(height: 4),
                    Text('${item['sumber']} • ${item['durasi']} Menit', style: const TextStyle(color: Colors.black45, fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.black26),
                itemBuilder: (context) => [
                  PopupMenuItem(child: const Text('Edit'), onTap: () => Future.delayed(Duration.zero, () => _startEditing(index, item))),
                  PopupMenuItem(child: const Text('Hapus', style: TextStyle(color: Colors.red)), onTap: () => vm.removeCeramah(index)),
                ],
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF0EDFF)),
          ),
          Text(
            item['rangkuman'] ?? '',
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text('Belum ada ilmu yang dicatat hari ini', style: TextStyle(color: Colors.black38)),
      ],
    );
  }
}