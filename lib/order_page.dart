import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatelessWidget {
  final String nama;
  final String meja;
  final String pesanan;

  const OrderPage({
    Key? key,
    required this.nama,
    required this.meja,
    required this.pesanan,
  }) : super(key: key);

  Future<void> _kirimPesanan(BuildContext context) async {
    String phone = "62816784408";
    String pesan = "Nama: $nama\nNomor Meja: $meja\nPesanan:$pesanan";
    String url = "https://wa.me/$phone?text=${Uri.encodeComponent(pesan)}";
    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal membuka WhatsApp. Pastikan sudah terinstal."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Konfirmasi Pesanan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: $nama", style: GoogleFonts.montserrat(fontSize: 16)),
            SizedBox(height: 10),
            Text("Nomor Meja: $meja", style: GoogleFonts.montserrat(fontSize: 16)),
            SizedBox(height: 10),
            Text("Pesanan:", style: GoogleFonts.montserrat(fontSize: 16)),
            SizedBox(height: 6),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  pesanan,
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _kirimPesanan(context),
                    child: Text("Kirim via WhatsApp"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
