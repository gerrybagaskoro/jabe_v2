// To parse this JSON data, do
//
//     final report = reportFromJson(jsonString);

import 'dart:convert';

List<Report> reportListFromJson(String str) =>
    List<Report>.from(json.decode(str)["data"].map((x) => Report.fromJson(x)));

Report reportFromJson(String str) => Report.fromJson(json.decode(str)["data"]);

String reportToJson(Report data) => json.encode(data.toJson());

// Tambahkan class ReportStatistics
class ReportStatistics {
  int masuk;
  int proses;
  int selesai;

  ReportStatistics({
    required this.masuk,
    required this.proses,
    required this.selesai,
  });

  factory ReportStatistics.fromJson(Map<String, dynamic> json) =>
      ReportStatistics(
        masuk: json["masuk"] ?? 0,
        proses: json["proses"] ?? 0,
        selesai: json["selesai"] ?? 0,
      );

  // Hitung total
  int get total => masuk + proses + selesai;
}

class Report {
  int? id;
  String? judul;
  String? isi;
  String? lokasi;
  String? status;
  String? imageUrl;
  int? userId;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;

  Report({
    this.id,
    this.judul,
    this.isi,
    this.lokasi,
    this.status,
    this.imageUrl,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json["id"],
    judul: json["judul"],
    isi: json["isi"],
    lokasi: json["lokasi"],
    status: json["status"],
    imageUrl: json["image_url"],
    userId: json["user_id"] is String
        ? int.tryParse(json["user_id"])
        : json["user_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "judul": judul,
    "isi": isi,
    "lokasi": lokasi,
    "status": status,
    "image_url": imageUrl,
    "user_id": userId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user": user?.toJson(),
  };

  // Getter untuk kompatibilitas dengan kode yang ada
  String get title => judul ?? '';
  String get description => isi ?? '';
  String get location => lokasi ?? '';
}

class User {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
