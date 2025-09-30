import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:csv/csv.dart';

class ReportDisplayScreen extends StatelessWidget {
  final List<dynamic> reportData;
  final DateTime date;
  final bool isMonthlyReport;

  const ReportDisplayScreen({
    super.key,
    required this.reportData,
    required this.date,
    this.isMonthlyReport = false,
  });

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final title = isMonthlyReport
        ? "Rapport de ${DateFormat('MMMM yyyy', 'fr_FR').format(date)}"
        : "Rapport du ${DateFormat('dd/MM/yyyy').format(date)}";

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Agent', 'Positions', 'Missions Terminées', 'Première Activité', 'Dernière Activité'],
                data: reportData.map((row) {
                  final firstActivity = row['firstActivity'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(row['firstActivity']).toLocal()) : 'Aucune activité';
                  final lastActivity = row['lastActivity'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(row['lastActivity']).toLocal()) : 'Aucune activité';
                  return [row['agentName'] ?? '', row['positionsCount'].toString(), row['completedMissionsCount'].toString(), firstActivity, lastActivity];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/rapport.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  Future<void> _generateCsv(BuildContext context) async {
    List<List<dynamic>> rows = [];
    rows.add(['Agent', 'Positions', 'Missions Terminées', 'Première Activité', 'Dernière Activité']);
    for (var row in reportData) {
      final firstActivity = row['firstActivity'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(row['firstActivity']).toLocal()) : 'Aucune activité';
      final lastActivity = row['lastActivity'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(row['lastActivity']).toLocal()) : 'Aucune activité';
      rows.add([row['agentName'] ?? '', row['positionsCount'].toString(), row['completedMissionsCount'].toString(), firstActivity, lastActivity]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/rapport.csv");
    await file.writeAsString(csv);
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat timeFormatter = DateFormat('HH:mm:ss');
    final String title = isMonthlyReport
        ? "Rapport de ${DateFormat('MMMM yyyy').format(date)}"
        : "Rapport du ${DateFormat('dd/MM/yyyy').format(date)}";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
            tooltip: 'Exporter en PDF',
          ),
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () => _generateCsv(context),
            tooltip: 'Exporter en CSV',
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Agent', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Positions', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Missions Terminées', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Première Activité', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Dernière Activité', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: reportData.map((row) {
              final firstActivity = row['firstActivity'] != null ? timeFormatter.format(DateTime.parse(row['firstActivity']).toLocal()) : 'Aucune activité';
              final lastActivity = row['lastActivity'] != null ? timeFormatter.format(DateTime.parse(row['lastActivity']).toLocal()) : 'Aucune activité';

              return DataRow(cells: [
                DataCell(Text(row['agentName'] ?? '')),
                DataCell(Text(row['positionsCount'].toString())),
                DataCell(Text(row['completedMissionsCount'].toString())),
                DataCell(Text(firstActivity)),
                DataCell(Text(lastActivity)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
