import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // void _incrementCounter() async {
  //   final data = {
  //     "merchantId": "MERCHANTUAT",
  //     "merchantTransactionId": "MT7850590068188104",
  //     "merchantUserId": "MU933037302229373",
  //     "amount": 100,
  //     "callbackUrl": "https://webhook.site/callback-url",
  //     "mobileNumber": "9999999999",
  //     "deviceContext": {"deviceOS": "ANDROID"},
  //     "paymentInstrument": {
  //       "type": "UPI_INTENT",
  //       "targetApp": "com.phonepe.app",
  //       "accountConstraints": [
  //         {
  //           //Optional. Required only for TPV Flow.
  //           "accountNumber": "420200001892",
  //           "ifsc": "ICIC0000041"
  //         }
  //       ]
  //     }
  //   };
  //
  //   final b64 = jsonEncode(data).toBase64;
  //
  //   print(b64);
  //
  //   const saltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  //
  //   final sha = '$b64/pg/v1/pay$saltKey'.toSha256;
  //   print(sha);
  //   try {
  //     final res = await http.post(
  //       Uri.parse('https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/pay'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'X-VERIFY': '$sha###1',
  //       },
  //     );
  //
  //     print(res.body.toString());
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  final saltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  final saltIndex = 1;
  final apiEndpoint = "/pg/v1/pay";

  String jsonString = "";
  String base64Data = "";
  String dataToHash = "";
  String sHA256 = "";
  Object? result;

  @override
  void initState() {// TODO: implement initState
    super.initState();
    phonePeInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$result',
            ),
            Text(
              '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: test,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void test() async {

    print(base64Data);
    print('#' * 10);
    print("$sHA256###$saltIndex");

    try {
      var response = PhonePePaymentSdk.startPGTransaction(
          base64Data, "https://webhook.site/4975f9f4-fd9e-44ef-adc4-c564c022dfce",
          "$sHA256###$saltIndex", {
        "accept": "application/json",
        'X-VERIFY': '$sHA256###$saltIndex',
        'Content-Type': 'application/json',
      }, '/pg/v1/pay', 'com.phonepe.app');
      debugPrint("---response----${response}");

      response
          .then((val) => {
        setState(() {
          result = val;
        })
      })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }

    final response = await http.post(
      // Uri.parse('https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/pay'),
      Uri.parse('https://api-preprod.phonepe.com/apis/hermes/pg/v1/pay'),
      headers: {
        "accept": "application/json",
        'X-VERIFY': '$sHA256###$saltIndex',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'request': base64Data}),
    );

    log(response.body.toString());

  }

  String generateSha256Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void phonePeInit() {


    final jsonData = {
      "merchantId": "PGTESTPAYUAT",
      "merchantTransactionId": "MT7850590068188104",
      "merchantUserId": "MUID123",
      "amount": 1000,
      "redirectUrl": "https://webhook.site/redirect-url",
      "redirectMode": "POST",
      "callbackUrl": "https://webhook.site/callback-url",
      "mobileNumber": "9999999999",
      "paymentInstrument": {
        "type": "UPI_INTENT",
        "targetApp": "com.phonepe.app"
      },
      "deviceContext" : {
        "deviceOS": "ANDROID"
      }
    };

    jsonString = jsonEncode(jsonData);
    base64Data = jsonString.toBase64;
    dataToHash = base64Data + apiEndpoint + saltKey;
    sHA256 = generateSha256Hash(dataToHash);

    // print(base64Data);
    // print('#' * 10);
    // print("$sHA256###$saltIndex");

    setState(() {});

    PhonePePaymentSdk.init("UAT", "", "PGTESTPAYUAT", true)
        .then((val) => {
      setState(() {
        result = 'PhonePe SDK Initialized - $val';
      })
    })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void handleError(error) {
    print("Error-->$error");
  }
}

/// EncodingExtensions
extension EncodingExtensions on String {
  /// To Base64
  /// This is used to convert the string to base64
  String get toBase64 {
    return base64.encode(toUtf8);
  }

  /// To Utf8
  /// This is used to convert the string to utf8
  List<int> get toUtf8 {
    return utf8.encode(this);
  }

  /// To Sha256
  /// This is used to convert the string to sha256
  String get toSha256 {
    return sha256.convert(toUtf8).toString();
  }
}