import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Visa extends StatefulWidget {
  const Visa({
    super.key,
  });

  @override
  State<Visa> createState() => _VisaState();
}

class Responses {
  const Responses({
    required this.embassy,
    required this.name,
    required this.dob,
    required this.nationality,
    required this.passport,
    required this.issued,
    required this.expires,
    required this.employer,
    required this.payee,
    required this.attendee,
  });

  final String embassy;
  final String name;
  final String dob;
  final String nationality;
  final String passport;
  final String issued;
  final String expires;
  final String employer;
  final String payee;
  final String attendee;
}

class _VisaState extends State<Visa> {
  bool wideScreen = false;
  int selectedIndex = 0;

  final embassy = TextEditingController();
  final name = TextEditingController();
  final dob = TextEditingController();
  final nationality = TextEditingController();
  final passport = TextEditingController();
  final issued = TextEditingController();
  final expires = TextEditingController();
  String? payee;
  String? attendee;
  final employer = TextEditingController();

  void inputChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    embassy.addListener(inputChanged);
    name.addListener(inputChanged);
    dob.addListener(inputChanged);
    nationality.addListener(inputChanged);
    passport.addListener(inputChanged);
    issued.addListener(inputChanged);
    expires.addListener(inputChanged);
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
                  TextFormField(
                    decoration: const InputDecoration(labelText: "I am sending this letter to"),
                    controller: embassy,
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
                  payee == "employer"
                      ? TextFormField(
                          decoration: const InputDecoration(labelText: "I am employed by"),
                          controller: employer,
                        )
                      : Container(),
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: "attendee", child: Text("attendee")),
                      DropdownMenuItem(value: "speaker", child: Text("presenter")),
                    ],
                    onChanged: (item) => {
                      setState(() {
                        attendee = item!;
                      })
                    },
                    value: attendee,
                    decoration: const InputDecoration(labelText: "I am a CppCon"),
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
      pdfFileName: "CppCon 2025 Visa Letter.pdf",
    );

    return Title(
        title: "CppCon Visa",
        color: Colors.black,
        child: Scaffold(
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
          appBar: AppBar(title: const Text("CppCon Visa")),
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
        ));
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final responses = Responses(
      embassy: stringOrDefault(embassy.text, "[EMBASSY]"),
      name: stringOrDefault(name.text, "[NAME]"),
      dob: stringOrDefault(dob.text, "[DOB]"),
      nationality: stringOrDefault(nationality.text, "[NATIONALITY]"),
      passport: stringOrDefault(passport.text, "[NUMBER]"),
      issued: stringOrDefault(issued.text, "[ISSUED]"),
      expires: stringOrDefault(expires.text, "[EXPIRES]"),
      employer: stringOrDefault(employer.text, "[EMPLOYER]"),
      payee: stringOrDefault(payee, "myself"),
      attendee: stringOrDefault(attendee, "attendee"),
    );
    var payeeSentence = switch (responses.payee) {
      "employer" =>
        "All costs related to ${responses.name}’s travel, accommodation, and conference fees are being fully paid for by their employer, ${responses.employer}.\n\n",
      "foundation" =>
        "All costs related to ${responses.name}’s travel, accommodation, and conference fees are being fully paid for by the Standard C++ Foundation.\n\n",
      _ => "",
    };

    final pdf = pw.Document();
    final bold = pw.TextStyle(inherit: true, fontWeight: pw.FontWeight.bold);
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
          pw.Text("522 W. Riverside Ave., Suite 5330\nSpokane, WA 99201\nTel: (253) 260-3819\n\n"),
          pw.Text("To whom it may concern at ${responses.embassy},\n\n"),
          pw.RichText(
            text: pw.TextSpan(children: [
              const pw.TextSpan(
                  text: "The Standard C++ Foundation is pleased to formally invite the following individual to attend"),
              pw.TextSpan(text: "CppCon 2025,", style: bold),
              const pw.TextSpan(text: " to be held in Aurora, Colorado, USA\n\n"),
            ]),
            textAlign: pw.TextAlign.justify,
          ),
          pw.Container(
              height: 160,
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
          pw.RichText(
            text: pw.TextSpan(children: [
              const pw.TextSpan(text: "\nCppCon is the annual, week-long, "),
              pw.TextSpan(text: "flagship conference for the global C++ software development community. ", style: bold),
              const pw.TextSpan(
                  text:
                      "The conference brings together C++ programmers, researchers, and software industry leaders from across the world to share knowledge, exchange ideas, and advance the state of the art in C++ development.\n\nAttendees include "),
              pw.TextSpan(
                  text:
                      "engineers, technical leads, educators, authors, open-source contributors, and members of the C++ standards committee, ",
                  style: bold),
              const pw.TextSpan(
                  text:
                      "representing companies and institutions from every corner of the globe.\n\nThis conference is critical to the ongoing development and education within the software engineering community, particularly those working with C++. It fosters collaboration, showcases new technologies and innovations, and plays a vital role in shaping the future of the C++ programming language.\n\n"),
            ]),
            textAlign: pw.TextAlign.justify,
          ),
          pw.Text(
              "${responses.name} has registered to attend CppCon 2025 in order to participate in technical sessions, networking opportunities, and collaborative events with peers and industry leaders.\n\n$payeeSentence",
              textAlign: pw.TextAlign.justify),
          responses.attendee == "speaker" ? pw.Text("As ${responses.name} is presenting at CppCon 2025 it is crucial that they be able to physically attend in order to effectively share their insights and engage with other attendees.\n\n", style: bold) : pw.Text(""),
          pw.Text(
              "We respectfully request your assistance in facilitating a visa for ${responses.name} to attend this important event. We look forward to welcoming them to the United States and to CppCon 2025.\n\n",
              textAlign: pw.TextAlign.justify),
          pw.Text("Please do not hesitate to contact us should you require any additional information.",
              textAlign: pw.TextAlign.justify),
          pw.Text("\nBest regards,\n\n"),
          pw.Image(pw.MemoryImage(Uint8List.view(sigImage.buffer)), height: 0.69 * PdfPageFormat.inch),
          pw.Text("\nJon Kalb, CppCon 2025 Conference Chair"),
          pw.Text("admin@isocpp.org")
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
