import 'package:flutter/material.dart';
import 'package:paynow/blocs/interface_manager.dart';

import 'blocs/transcation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Color(0xff101010),
          canvasColor: Color(0xff101010),
          accentColor: Colors.purple,
          textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white))),
      title: 'Pay Now',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final InterfaceManager manager = new InterfaceManager();

  double currentBalance = 0;
  final User currentUser = new User("1", "Emmanuel", 10000000);
  final User systemBot = new User("2", "Bot", 100500000);
  double transactionAmount;

  @override
  void setState(fn) {
    super.setState(fn);
    print('statuses : ${manager.statuses}');
  }

  @override
  void dispose() {
    manager.statuses.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('PayNow Banking'),
          centerTitle: true,
        ),
        body: new StreamBuilder(
          stream: manager.statuses.stream,
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.hasData){
              if (snapshot.data != InterfaceManagerMessage.clearProgressIndicator) {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                   Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(manager.updateWithAlertMessage(snapshot.data)))));
              }
              if(snapshot.data == InterfaceManagerMessage.clearProgressIndicator){
                 manager.clearTransactionProgress();

              }
            }
           
            bool isEmpty = snapshot.data == InterfaceManagerMessage.emptyAmountField;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  snapshot.data != InterfaceManagerMessage.clearProgressIndicator && snapshot.hasData ?
                       LinearProgressIndicator(
                          value: isEmpty ? 1.0 : manager.transactionProgess,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: isEmpty
                              ? AlwaysStoppedAnimation<Color>(Colors.red)
                              : AlwaysStoppedAnimation<Color>(Colors.green)) : 
                              new Container(),
              
                  new Container(
                    margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent,
                            ),
                            child: new Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'Balance: \$${currentUser.getBalance()}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ))),
                      ],
                    ),
                  ),
                  new SizedBox(height: 20),
                  TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      
                      onChanged: (amount) {
                        transactionAmount = double.parse(amount);
                      },
                      maxLength: 5,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                      
                    
                        hintText: '0.00',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 80,
                            fontWeight: FontWeight.w500),
                      )),
                  new RaisedButton(
                    onPressed: () async {
                      // create transaction
                      FocusManager.instance.primaryFocus.unfocus();
                      await manager.createTransaction(
                          currentUser, systemBot, transactionAmount);

                      setState(() {
                        currentBalance = currentUser.getBalance();
                      });
                    },
                    child: new Text("Start"),
                    color: Colors.purple,
                    textColor: Colors.white,
                  ),
                ]);
          },
        ),
      ),
    );
  }
}
