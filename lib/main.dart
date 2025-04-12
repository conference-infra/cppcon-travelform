import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


void main() {
  runApp(const TravelFormApp());
}

class TravelFormApp extends StatelessWidget {
  const TravelFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CppCon Invitation',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}


class Responses {
  const Responses({
    required this.name,
    required this.dob,
    required this.nationality,
    required this.passport,
    required this.issued,
    required this.expires,
    required this.entering,
    required this.exiting,
    required this.attendee,
    required this.employer,
    required this.payee,
  });

  final String name;
  final String dob;
  final String nationality;
  final String passport;
  final String issued;
  final String expires;
  final String entering;
  final String exiting;
  final String attendee;
  final String employer;
  final String payee;
}

class _HomeState extends State<Home> {
  bool wideScreen = false;
  int selectedIndex = 0;

  final name = TextEditingController();
  final dob = TextEditingController();
  final nationality = TextEditingController();
  final passport = TextEditingController();
  final issued = TextEditingController();
  final expires = TextEditingController();
  DateTime? entering;
  final enteringText = TextEditingController();
  DateTime? exiting;
  final exitingText = TextEditingController();
  String? attendee;
  String? payee;
  final employer = TextEditingController();

  void inputChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    name.addListener(inputChanged);
    dob.addListener(inputChanged);
    nationality.addListener(inputChanged);
    passport.addListener(inputChanged);
    issued.addListener(inputChanged);
    expires.addListener(inputChanged);
    enteringText.addListener(inputChanged);
    exitingText.addListener(inputChanged);
    employer.addListener(inputChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width;
    wideScreen = width > 600;
  }

  String stringOrDefault(String? s, String def) {
    return (s?.isNotEmpty ?? false) ? s! : def;
  }

  String dateOrDefault(DateTime? d, String def) {
    if (d == null) {
      return def;
    }

    return DateFormat("MM/dd/yyyy").format(d);
  }

  @override
  Widget build(BuildContext context) {
    final edit = Form(
        child: ListView(
      padding: const EdgeInsets.only(right: 10),
      children: [
        Text(
          "Instructions",
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          "Please complete all fields and proof read the generated document for correctness.\n",
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        Text(
          "All information is processed locally in your browser and never transmitted anywhere.\n",
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        Card.outlined(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: "an attendee", child: Text("attendee")),
                      DropdownMenuItem(value: "a speaker", child: Text("speaker")),
                      DropdownMenuItem(value: "a panelist", child: Text("panelist")),
                      DropdownMenuItem(value: "an exhibitor", child: Text("exhibitor")),
                    ],
                    onChanged: (item) => {
                      setState(() {
                        attendee = item!;
                      })
                    },
                    value: attendee,
                    decoration: const InputDecoration(labelText: "I am a CppCon"),
                  ),
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: "myself", child: Text("myself")),
                      DropdownMenuItem(value: "employer", child: Text("my employer")),
                      DropdownMenuItem(value: "foundation", child: Text("the Standard C++ Foundation")),
                    ],
                    onChanged: (item) => {
                      setState(() {
                        payee = item!;
                      })
                    },
                    value: payee,
                    decoration: const InputDecoration(labelText: "I am financially sponsored by"),
                  ),
                  payee == "employer" ? TextFormField(
                    decoration: const InputDecoration(labelText: "I am employed by"),
                    controller: employer,
                  ) : Container(),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "I am entering the USA on"),
                    controller: enteringText,
                    readOnly: true,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2026),
                        currentDate: DateTime(2025, 9, 17),
                        initialDate: entering,
                      );
                      setState(() {
                        entering = d;
                        enteringText.text = dateOrDefault(d, "");
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "I am leaving the USA on"),
                    controller: exitingText,
                    readOnly: true,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2026),
                        currentDate: DateTime(2025, 9, 17),
                        initialDate: exiting,
                      );
                      setState(() {
                        exiting = d;
                        exitingText.text = dateOrDefault(d, "");
                      });
                    },
                  ),
                ]))),
        Card.outlined(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  Text(
                    "Passport Information",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Please enter the following fields exactly as they appear on your passport",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Full Name"),
                    controller: name,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Date of Birth"),
                    controller: dob,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Issuing Country"),
                    controller: nationality,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Document Number"),
                    controller: passport,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Issued On"),
                    controller: issued,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Expires On"),
                    controller: expires,
                  ),
                ]))),
      ],
    ));
    final preview = PdfPreview(
      build: _buildPdf,
      shouldRepaint: true,
      canChangeOrientation: false,
      canChangePageFormat: false,
      enableScrollToPage: true,
      pdfFileName: "CppCon 2025 Invitation Letter.pdf",
    );

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: wideScreen
              ? Row(
                  children: [SizedBox(width: 300, child: edit), Expanded(child: preview)],
                )
              : switch (selectedIndex) {
                  0 => edit,
                  1 => preview,
                  _ => throw Exception("bad nav"),
                }),
      appBar: AppBar(title: const Text("CppCon Invitation")),
      bottomNavigationBar: wideScreen
          ? null
          : NavigationBar(
              destinations: const [
                  NavigationDestination(icon: Icon(Icons.edit), label: "Edit"),
                  NavigationDestination(icon: Icon(Icons.preview), label: "Preview"),
                ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => setState(() {
                    selectedIndex = i;
                  })),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final responses = Responses(
      name: stringOrDefault(name.text, "[NAME]"),
      dob: stringOrDefault(dob.text, "[DOB]"),
      nationality: stringOrDefault(nationality.text, "[NATIONALITY]"),
      passport: stringOrDefault(passport.text, "[NUMBER]"),
      issued: stringOrDefault(issued.text, "[ISSUED]"),
      expires: stringOrDefault(expires.text, "[EXPIRES]"),
      entering: stringOrDefault(enteringText.text, "[ENTERING]"),
      exiting: stringOrDefault(exitingText.text, "[LEAVING]"),
      attendee: stringOrDefault(attendee, "[ATTENDEE TYPE]"),
      employer: stringOrDefault(employer.text, "[EMPLOYER]"),
      payee: stringOrDefault(payee, "myself"),
    );
    var payeeSentence = switch (responses.payee) {
      "employer" => "All costs related to ${responses.name}’s travel, accommodation, and conference fees are being fully paid for by their employer, ${responses.employer}.  ",
      "foundation" => "All costs related to ${responses.name}’s travel, accommodation, and conference fees are being fully paid for by the Standard C++ Foundation.  ",
      _ => "",
    };

    final pdf = pw.Document();
    final bold = pw.TextStyle(inherit: true, fontWeight: pw.FontWeight.bold);
    final boldUnderline = pw.TextStyle(
        inherit: true, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline, decorationThickness: 2);
    final logoImage = await rootBundle.load("assets/logo.png");
    final sigImage = await rootBundle.load("assets/signature.png");
    final normalFont = pw.TtfFont(await rootBundle.load("assets/Arial.ttf"));
    final boldFont = pw.TtfFont(await rootBundle.load("assets/Arial_Bold.ttf"));
    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
          pw.Center(
              child: pw.Image(pw.MemoryImage(Uint8List.view(logoImage.buffer)), height: 0.55 * PdfPageFormat.inch)),
          pw.Text("\n"),
          pw.Row(children: [
            pw.Text("Standard C++ Foundation", style: bold),
            pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
          ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
          pw.Text(
              "522 W. Riverside Ave., Suite 5330\nSpokane, WA 99201\n\nU.S. Department of Homeland Security\nU.S. Customs and Border Protection\n\n"),
          pw.Text("Re:    Application for Entry as a Visitor for Business\n\n", style: bold),
          pw.RichText(
            text: pw.TextSpan(children: [
              const pw.TextSpan(
                  text:
                      "The Standard C++ Foundation is pleased to confirm that the following individual is scheduled to attend "),
              pw.TextSpan(text: "CppCon 2025,", style: bold),
              const pw.TextSpan(
                  text:
                      " a major international software development conference, taking place in Aurora, Colorado, USA.\n\n"),
            ]),
            textAlign: pw.TextAlign.justify,
          ),
          pw.Container(
              height: 200,
              child: pw.GridView(crossAxisCount: 2, crossAxisSpacing: -200, children: [
                pw.Text("Event Name:", style: bold),
                pw.Text("CppCon 2025"),
                pw.Text("Event Website:", style: bold),
                pw.Text("https://cppcon.org"),
                pw.Text("Event Dates:", style: bold),
                pw.Text("September 13–19, 2025"),
                pw.Text("Event Location:", style: bold),
                pw.Text("Gaylord Rockies Resort and Convention Center"),
                pw.Text(""),
                pw.Text("6700 North Gaylord Rockies Blvd., Aurora, Colorado, 80019, USA"),
                pw.Text("\n"),
                pw.Text("\n"),
                pw.Text("Attendee Information:", style: bold),
                pw.Text(""),
                pw.Text("\n"),
                pw.Text("\n"),
                pw.Text("Full Name:", style: bold),
                pw.Text(responses.name),
                pw.Text("Date of Birth:", style: bold),
                pw.Text(responses.dob),
                pw.Text("Nationality:", style: bold),
                pw.Text(responses.nationality),
                pw.Text("Passport Number:", style: bold),
                pw.Text(responses.passport),
                pw.Text("Passport Issue Date:", style: bold),
                pw.Text(responses.issued),
                pw.Text("Passport Expiry Date:", style: bold),
                pw.Text(responses.expires),
              ])),
          pw.Text(
              "\nDear Officer:\n\nThis letter is submitted in support of ${responses.name}’s entry as a visitor for business. The Standard C++ Foundation has invited ${responses.name}, a citizen of ${responses.nationality}, to enter the United States to attend a professional software development conference. ${responses.name} plans to be in the United States from ${responses.entering} to ${responses.exiting}. During this time, they will not engage in productive employment with any U.S. entity. They will only be entering the United States as ${responses.attendee} for the conference.",
              textAlign: pw.TextAlign.justify),
          pw.Text("\nEvent Information\n\n", style: boldUnderline, textAlign: pw.TextAlign.center),
          pw.Text(
              "CppCon is the premier annual conference for the international C++ programming community. Attendees include engineers, educators, researchers, and industry leaders from around the world. The event features technical presentations, panels, networking opportunities, and sessions that advance the field of C++ software development.",
              textAlign: pw.TextAlign.justify),
          pw.Text(
              "\nCppCon’s goal is to encourage the best use of C++ while preserving the diversity of viewpoints and experiences. The conference is a project of the Standard C++ Foundation, a not-for-profit organization whose purpose is to support the global C++ software developer community and promote the understanding and use of modern, standard C++ on all compilers and platforms. The Foundation provides and supports these globally inclusive forums for the world’s C++ technologists to collaborate.",
              textAlign: pw.TextAlign.justify),
          pw.Text("\nPurpose of the Business Visit\n\n", style: boldUnderline, textAlign: pw.TextAlign.center),
          pw.Text(
              "\n${responses.name} is attending as ${responses.attendee} and is expected to be present for the full duration of the conference. Their attendance supports ongoing professional development, technical collaboration, and knowledge exchange in a global community of software professionals.",
              textAlign: pw.TextAlign.justify),
          pw.Text(
              "\nAt no time will ${responses.name} be working in the United States. They will not engage in any productive employment for any U.S. entity. For the entirety of their stay in the United States, ${responses.name} will have sufficient funds to bear the expenses of their stay. ${payeeSentence}At the conclusion of the conference, ${responses.name} will return to their home country of ${responses.nationality}.",
              textAlign: pw.TextAlign.justify),
          pw.Text(
              "\nWe respectfully request that ${responses.name} be allowed entry into the United States for the purpose of attending this professional conference.",
              textAlign: pw.TextAlign.justify),
          pw.Text(
              "\nPlease feel free to contact us directly should you require any additional information regarding this event or ${responses.name}’s participation.",
              textAlign: pw.TextAlign.justify),
          pw.Text("\nBest regards,\n\n"),
          pw.Image(pw.MemoryImage(Uint8List.view(sigImage.buffer)), height: 0.69 * PdfPageFormat.inch),
          pw.Text("\nJon Kalb, CppCon 2025 Conference Chair"),
          pw.Text(
              "\nOn behalf of the Standard C++ Foundation / CppCon 2025\nEmail: admin@isocpp.org\nTel: (253) 260-3819")
        ])
      ],
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(0.7 * PdfPageFormat.inch),
        theme: pw.ThemeData.base().copyWith(
          defaultTextStyle: pw.TextStyle.defaultStyle()
              .copyWith(fontNormal: normalFont, fontBold: boldFont, fontSize: 10.0 * PdfPageFormat.point),
        ),
      ),
    ));
    return pdf.save();
  }
}
