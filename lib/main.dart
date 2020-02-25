import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _defaultSpacing = 16.0;

  static const _divError = "DIV0_ERR";
  static const _parseError = "PARSE_ERR";

  final _receiptTotalController = TextEditingController();
  final _receiptTotalExcludingTax = TextEditingController();
  final _receiptTaxController = TextEditingController();
  final _transactionTotalController = TextEditingController();
  final _splitController1 = TextEditingController();
  final _splitController2 = TextEditingController();
  final _splitController3 = TextEditingController();
  final _splitController4 = TextEditingController();
  final _splitController5 = TextEditingController();

  double _exchangeRate = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(_defaultSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _buildTextField(
                    title: "Receipt Total",
                    controller: _receiptTotalController,
                  ),
                  _horizontalSpacer,
                  _buildTextField(
                    title: "Transaction Total",
                    controller: _transactionTotalController,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  _buildTextField(
                    title: "Receipt Total (Excluding Tax)",
                    controller: _receiptTotalExcludingTax,
                  ),
                  _horizontalSpacer,
                  Spacer(),
                ],
              ),
              Row(
                children: <Widget>[
                  _buildTextField(
                    title: "Receipt Tax Amount",
                    controller: _receiptTaxController,
                  ),
                  _horizontalSpacer,
                  Spacer(),
                ],
              ),
              _verticalSpacer,
              Text("Exchange Rate: \$${_calculateExchangeRate()}",
                style: Theme.of(context).textTheme.headline5,
              ),
              Text("Tax Rate: \$${_calculateTaxRate() ?? _parseError}",
                style: Theme.of(context).textTheme.headline5,
              ),
              _verticalSpacer,
              Text("Splits",
                style: Theme.of(context).textTheme.headline4,
              ),
              Text("Separate multiple items with a comma."),
              _verticalSpacer,
              _buildSplitRow(controller: _splitController1),
              _verticalSpacer,
              _buildSplitRow(controller: _splitController2),
              _verticalSpacer,
              _buildSplitRow(controller: _splitController3),
              _verticalSpacer,
              _buildSplitRow(controller: _splitController4),
              _verticalSpacer,
              _buildSplitRow(controller: _splitController5),
              _verticalSpacer,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    String title,
    TextEditingController controller,
  }) => Expanded(
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      onChanged: (text) {
        setState(() {
        });
      },
    ),
  );

  Widget _buildSplitRow({
    TextEditingController controller,
  }) {
    var items = [];
    if (controller.text != null) {
      items = controller.text.split(",");
    }

    var itemTotal = 0.0;
    var itemTotalString;
    for (var item in items) {
      try {
        itemTotal += double.parse(item);
      } on Exception {
        itemTotalString = _parseError;
        break;
      }
    }

    var exchangeTotalString;
    var taxPercent = _calculateTaxRate();
    if (itemTotalString == null && taxPercent != null) {
      itemTotalString = itemTotal.toStringAsFixed(2);
      exchangeTotalString = (itemTotal * (taxPercent + 1)
          * _exchangeRate).toStringAsFixed(2);
    } else {
      itemTotalString = _parseError;
      exchangeTotalString = _parseError;
    }

    return Row(
      children: <Widget>[
        _buildTextField(title: "Description"),
        _horizontalSpacer,
        _buildTextField(title: "Items", controller: controller),
        _horizontalSpacer,
        Text("\$$itemTotalString x ${_exchangeRate.toString()} = "),
        Text("\$$exchangeTotalString",
          style: Theme.of(context).textTheme.headline5,
        ),
      ],
    );
  }

  Widget get _horizontalSpacer => Container(width: _defaultSpacing);
  Widget get _verticalSpacer => Container(height: _defaultSpacing);

  String _calculateExchangeRate() {
    try {
      if (_receiptTotalController.text == null
          || _receiptTotalController.text.isEmpty
          || _transactionTotalController.text == null
          || _transactionTotalController.text.isEmpty)
      {
        return _exchangeRate.toString();
      }

      double _receiptTotal = double.parse(_receiptTotalController.text);
      double _transactionTotal = double.parse(_transactionTotalController.text);

      if (_receiptTotal == null || _receiptTotal <= 0) {
        return _divError;
      }

      _exchangeRate = _transactionTotal / _receiptTotal;
      return _exchangeRate.toString();
    } on Exception {
      return _parseError;
    }
  }

  double _calculateTaxRate() {
    double taxPercent;
    if (_receiptTaxController.text != null
        && _receiptTotalExcludingTax.text != null)
    {
      var totalExcludingTax = double.tryParse(_receiptTotalExcludingTax.text);
      var taxAmount = double.tryParse(_receiptTaxController.text);
      print("Total excluding tax $totalExcludingTax");
      print("Tax amount          $taxAmount");
      if (totalExcludingTax != null && taxAmount != null) {
        taxPercent = taxAmount / totalExcludingTax;
      }
    }
    return taxPercent;
  }
}
