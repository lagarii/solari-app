import 'package:flutter/material.dart';
import '../services/api.dart';
import 'sohbet_ekrani.dart';

class DogumEkrani extends StatefulWidget {
  const DogumEkrani({super.key});

  @override
  State<DogumEkrani> createState() => _DogumEkraniState();
}

class _DogumEkraniState extends State<DogumEkrani> {
  final isimCtrl = TextEditingController();
  final sehirCtrl = TextEditingController();
  DateTime secilenTarih = DateTime(1990, 1, 1, 12, 0);
  bool yukleniyor = false;

  Future<void> _hesapla() async {
    if (isimCtrl.text.isEmpty || sehirCtrl.text.isEmpty) return;
    setState(() => yukleniyor = true);
    try {
      final data = await ApiService.nakshatraHesapla(
        isim: isimCtrl.text,
        yil: secilenTarih.year,
        ay: secilenTarih.month,
        gun: secilenTarih.day,
        saat: secilenTarih.hour,
        dakika: secilenTarih.minute,
        sehir: sehirCtrl.text,
        ulke: 'TR',
      );
      if (mounted && data['nakshatra'] != null) {
        final dogumTarihi =
            '${secilenTarih.year}-${secilenTarih.month.toString().padLeft(2, '0')}-${secilenTarih.day.toString().padLeft(2, '0')}';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SohbetEkrani(
              nakshatra: data['nakshatra'],
              dogumTarihi: dogumTarihi,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
    setState(() => yukleniyor = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✦ SOLARI', style: TextStyle(fontSize: 24, letterSpacing: 6, color: Colors.white)),
                const SizedBox(height: 32),
                const Text('Doğum Bilgilerin', style: TextStyle(fontSize: 20, color: Colors.white)),
                const SizedBox(height: 24),
                TextField(
                  controller: isimCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('Adın'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sehirCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('Doğum Şehri'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  tileColor: Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.white24)),
                  title: const Text('Doğum Tarihi & Saati', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  subtitle: Text(
                    '${secilenTarih.day}/${secilenTarih.month}/${secilenTarih.year}  ${secilenTarih.hour.toString().padLeft(2,'0')}:${secilenTarih.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.white54),
                  onTap: () async {
                    final tarih = await showDatePicker(
                      context: context,
                      initialDate: secilenTarih,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (tarih != null && mounted) {
                      final saat = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: secilenTarih.hour, minute: secilenTarih.minute),
                      );
                      if (saat != null) {
                        setState(() => secilenTarih = DateTime(tarih.year, tarih.month, tarih.day, saat.hour, saat.minute));
                      }
                    }
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: yukleniyor ? null : _hesapla,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF533483),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: yukleniyor
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Yıldız Haritamı Göster ✦', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF533483))),
  );
}
