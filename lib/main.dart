import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as myhttp;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/menu_model.dart';
import 'providers/cart_provider.dart';
import 'order_page.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.green),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  TextEditingController namaController = TextEditingController();
  TextEditingController nomorMejaController = TextEditingController();

  final String urlMenu =
      "https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLh7WlhvKBiIrA_cRkujMeK2ZRDRv-NRMuA0t1jodObJVffMebq-uEDQIUC4aWg_FzcRzmLj2RSoRIFNjmcxsCR6ip5vWcEFe8vQr9iaAfRP6PaqH2Yi2gEAiDkaR14PJqPWL3CB5TUrLyCN5op7PjpnDuKqHVGpJbFfwjOTRCh7J3QR1eJ-ZHp15qV-aWavzoUPLJpmvXwmGGpac_2yzWrnpeq9BD2IwzMSPsC8BvqDU8fLL3OvIJjH-EAxa4W5zULIVsEFMaj9WjtcAMqkqqE8AD9kkQ&lib=MWQQIg9GszXlYewCWmo_vgJFOgfsIIOTV";

  Future<List<MenuModel>> getAllData() async {
    final response = await myhttp.get(Uri.parse(urlMenu));
    List data = json.decode(response.body);
    return data.map((item) => MenuModel.fromJson(item)).toList();
  }

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 300,
            child: Column(
              children: [
                Text("Nama"),
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                Text("Nomor Meja"),
                TextFormField(
                  controller: nomorMejaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                Consumer<CartProvider>(
                  builder: (context, value, _) {
                    String strPesanan = "";
                    value.cart.forEach((element) {
                      strPesanan += "\n${element.name} (${element.quantity})";
                    });
return ElevatedButton(
  onPressed: () async {
    String nama = namaController.text.trim();
    String meja = nomorMejaController.text.trim();

    if (nama.isEmpty || meja.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Nama dan nomor meja wajib diisi."),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(meja)) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Nomor meja hanya boleh angka."),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    String strPesanan = "";
    value.cart.forEach((element) {
      strPesanan += "\n${element.name} (${element.quantity})";
    });

    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderPage(
          nama: nama,
          meja: meja,
          pesanan: strPesanan,
        ),
      ),
    );
  },
  child: Text("Pesan Sekarang"),
);
},
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog(context);
        },
        child: badges.Badge(
          badgeContent: Consumer<CartProvider>(
            builder: (context, value, _) {
              return Text(
                (value.total > 0) ? value.total.toString() : "",
                style: GoogleFonts.montserrat(color: Colors.white),
              );
            },
          ),
          child: Icon(Icons.shopping_bag, size: 30),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<MenuModel>>(
          future: getAllData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Tidak ada data menu."));
            }

            final menuList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuList.length,
              itemBuilder: (context, index) {
                final menu = menuList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 1,
                                maxScale: 4,
                                child: Image.network(menu.image),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(20)),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(menu.image),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                menu.description,
                                style: GoogleFonts.montserrat(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Rp ${menu.price}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Provider.of<CartProvider>(context,
                                                  listen: false)
                                              .addRemove(
                                                  menu.name, menu.id, false);
                                        },
                                        icon: Icon(Icons.remove_circle,
                                            color: Colors.red),
                                      ),
                                      Consumer<CartProvider>(
                                        builder: (context, value, _) {
                                          var id = value.cart.indexWhere(
                                              (e) => e.menuId == menu.id);
                                          return Text(
                                            (id == -1)
                                                ? '0'
                                                : value.cart[id]
                                                    .quantity
                                                    .toString(),
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Provider.of<CartProvider>(context,
                                                  listen: false)
                                              .addRemove(
                                                  menu.name, menu.id, true);
                                        },
                                        icon: Icon(Icons.add_circle,
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}