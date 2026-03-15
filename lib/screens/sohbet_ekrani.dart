import 'package:flutter/material.dart';
import '../services/api.dart';

class SohbetEkrani extends StatefulWidget {
  final String nakshatra;
  final String dogumTarihi;
  const SohbetEkrani({super.key, required this.nakshatra, this.dogumTarihi = ''});

  @override
  State<SohbetEkrani> createState() => _SohbetEkraniState();
}

class _SohbetEkraniState extends State<SohbetEkrani> {
  final soruCtrl = TextEditingController();
  final List<Map<String, String>> mesajlar = [];
  bool yukleniyor = false;
  int? kalanSoru;
  String secilenDil = 'tr';

  final Map<String, String> diller = {
    'tr': '🇹🇷 Türkçe', 'en': '🇺🇸 English', 'es': '🇪🇸 Español',
    'it': '🇮🇹 Italiano', 'pt': '🇧🇷 Português', 'hi': '🇮🇳 हिंदी', 'de': '🇩🇪 Deutsch',
  };

  @override
  void initState() {
    super.initState();
    _karsilamaGonder();
  }

  String get _bugun {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _karsilamaGonder() async {
    setState(() => yukleniyor = true);
    try {
      final data = await ApiService.soruSor(
        soru: '',
        nakshatra: widget.nakshatra,
        dil: secilenDil,
        dogumTarihi: widget.dogumTarihi,
        bugun: _bugun,
        karsilama: true,
      );
      setState(() {
        mesajlar.add({'tip': 'solari', 'metin': data['yanit'] ?? ''});
        kalanSoru = data['kalan_soru'];
      });
    } catch (e) {
      setState(() => mesajlar.add({
        'tip': 'solari',
        'metin': 'Ücretsiz soru hakkın doldu. Solari ile konuşmaya devam etmek için premium\'a geçebilirsin.',
      }));
    }
    setState(() => yukleniyor = false);
  }

  Future<void> _soruSor() async {
    if (soruCtrl.text.isEmpty) return;
    final soru = soruCtrl.text;
    soruCtrl.clear();
    setState(() {
      mesajlar.add({'tip': 'kullanici', 'metin': soru});
      yukleniyor = true;
    });
    try {
      final data = await ApiService.soruSor(
        soru: soru,
        nakshatra: widget.nakshatra,
        dil: secilenDil,
        dogumTarihi: widget.dogumTarihi,
        bugun: _bugun,
      );
      setState(() {
        mesajlar.add({'tip': 'solari', 'metin': data['yanit'] ?? 'Cevap alınamadı'});
        kalanSoru = data['kalan_soru'];
      });
    } catch (e) {
      setState(() => mesajlar.add({'tip': 'solari', 'metin': 'Bir hata oluştu: $e'}));
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('✦ SOLARI', style: TextStyle(fontSize: 18, letterSpacing: 4, color: Colors.white)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF533483), borderRadius: BorderRadius.circular(16)),
                      child: Text('${widget.nakshatra} ✦', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    if (kalanSoru != null)
                      Text('$kalanSoru soru', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: secilenDil,
                  dropdownColor: const Color(0xFF16213E),
                  style: const TextStyle(color: Colors.white),
                  underline: Container(height: 1, color: Colors.white24),
                  isExpanded: true,
                  items: diller.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) => setState(() => secilenDil = v!),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mesajlar.length + (yukleniyor ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == mesajlar.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF533483))),
                      );
                    }
                    final m = mesajlar[i];
                    final benMiyim = m['tip'] == 'kullanici';
                    return Align(
                      alignment: benMiyim ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: benMiyim ? const Color(0xFF533483) : Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(m['metin']!, style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: soruCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Yıldızlara sor...',
                          hintStyle: TextStyle(color: Colors.white38),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF533483))),
                        ),
                        onSubmitted: (_) => _soruSor(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: yukleniyor ? null : _soruSor,
                      icon: const Icon(Icons.send, color: Color(0xFF533483)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
