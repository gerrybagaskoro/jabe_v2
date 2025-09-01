// To parse this JSON data, do
//
//     final report = reportFromJson(jsonString);

import 'dart:convert';

List<Report> reportListFromJson(String str) =>
    List<Report>.from(json.decode(str).map((x) => Report.fromJson(x)));

Report reportFromJson(String str) => Report.fromJson(json.decode(str));

String reportToJson(Report data) => json.encode(data.toJson());

class Report {
  int? id;
  String? title;
  String? description;
  String? location;
  String? status;
  String? imageUrl;
  int? userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  Report({
    this.id,
    this.title,
    this.description,
    this.location,
    this.status,
    this.imageUrl,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    location: json["location"],
    status: json["status"],
    imageUrl: json["image_url"],
    userId: json["user_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "location": location,
    "status": status,
    "image_url": imageUrl,
    "user_id": userId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

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
