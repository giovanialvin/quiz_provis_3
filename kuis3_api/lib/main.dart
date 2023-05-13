import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

// ============= KUIS 3 API

// Landing Page

void main() {
  runApp(const MyApp());
}

class UMKMData {
  String id;
  String name;
  String jenis;
  UMKMData({required this.id, required this.name, required this.jenis});
}

class UMKMModel {
  List<UMKMData> listUMKM = <UMKMData>[];
  UMKMModel({required this.listUMKM});
}

class UMKMCubit extends Cubit<UMKMModel> {
  String url = "http://178.128.17.76:8000/daftar_umkm";

  UMKMCubit() : super(UMKMModel(listUMKM: []));

  void setFromJson(Map<String, dynamic> json) {
    List<UMKMData> list = <UMKMData>[];
    var data = json['data'];
    for (var val in data) {
      list.add(UMKMData(id: val['id'], name: val['nama'], jenis: val['jenis']));
    }
    emit(UMKMModel(listUMKM: list));
  }

  void fetchData() async {
    final response = await http.get(Uri.parse("$url"));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception("gagal load");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => UMKMCubit(),
        child: const HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz 3 Provis',
      home: Scaffold(
        appBar: AppBar(
            leading: FlutterLogo(),
            backgroundColor: Colors.blueGrey,
            title: Text('Quiz 3 Provis'),
            actions: <Widget>[ButtonNamaKelompok(), ButtonPerjanjian()]),
        body: Center(
          child: BlocBuilder<UMKMCubit, UMKMModel>(
            buildWhen: (prevState, state) {
              return true;
            },
            builder: (context, umkm) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<UMKMCubit>().fetchData();
                    },
                    child: const Text("Daftar UMKM"),
                  ),
                  Expanded(
                    child: Center(
                      //gunakan listview
                      child: ListView(
                        children: umkm.listUMKM
                            .map((umkm) => ListTile(
                                  title: Text(umkm.name.toString()),
                                  subtitle: Text(umkm.jenis.toString()),
                                  trailing: Icon(Icons.more_vert),
                                  onTap: () {
                                    //fungsi ketika ListTile diklik
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                  id: umkm.id.toString(),
                                                )));
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ButtonNamaKelompok extends StatelessWidget {
  const ButtonNamaKelompok({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.account_circle_rounded),
      onPressed: () {
        // icon account di tap
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Kelompok 5'),
            content: const Text(
                '(2000360) Muhammad Aditya (mdhstama@upi.edu) ; (2003721) Alvin Giovani (alvingiovani17@upi.edu)'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ButtonPerjanjian extends StatelessWidget {
  const ButtonPerjanjian({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.access_alarm_rounded),
      onPressed: () {
        // icon setting ditap
        const snackBar = SnackBar(
          duration: Duration(seconds: 20),
          content: Text(
              'Kami berjanji  tidak akan berbuat curang dan atau membantu kelompok lain berbuat curang'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }
}

// Detail Page

class DetailModel {
  String nama;
  String jenis;
  String omzet;
  String lama;
  String member;
  String jumlah;

  DetailModel({
    required this.nama,
    required this.jenis,
    required this.omzet,
    required this.lama,
    required this.member,
    required this.jumlah,
  });

  //map dari json ke atribut
  factory DetailModel.fromJson(Map<String, dynamic> json) {
    return DetailModel(
      nama: json['nama'],
      jenis: json['jenis'],
      omzet: json['omzet_bulan'],
      lama: json['lama_usaha'],
      member: json['member_sejak'],
      jumlah: json['jumlah_pinjaman_sukses'],
    );
  }
}

class DetailPage extends StatefulWidget {
  final String id;
  const DetailPage({Key? key, required this.id}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<DetailModel> futureDetail;
  late String url = "http://178.128.17.76:8000/detil_umkm/${widget.id}";

  @override
  void initState() {
    super.initState();
    futureDetail = fetchDetail();
  }

  Future<DetailModel> fetchDetail() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return DetailModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail UMKM"),
      ),
      body: Center(
        child: FutureBuilder<DetailModel>(
          future: futureDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nama UMKM: ${snapshot.data!.nama}'),
                  SizedBox(height: 16),
                  Text('Jenis UMKM: ${snapshot.data!.jenis}'),
                  SizedBox(height: 16),
                  Text('Omset Per Bulan: ${snapshot.data!.omzet}'),
                  SizedBox(height: 16),
                  Text('Lama Usaha: ${snapshot.data!.lama}'),
                  SizedBox(height: 16),
                  Text('Member Sejak: ${snapshot.data!.member}'),
                  SizedBox(height: 16),
                  Text('Jumlah Pinjaman Sukses: ${snapshot.data!.jumlah}'),
                  SizedBox(height: 16),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
