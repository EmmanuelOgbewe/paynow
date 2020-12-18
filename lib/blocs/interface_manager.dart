import 'dart:async';

import 'package:paynow/blocs/transcation.dart';

enum InterfaceManagerMessage{
  inProgress,
  emptyAmountField,
  clearProgressIndicator,
}

class InterfaceManager{ 

  TransactionManager manager = new TransactionManager();
  StreamController statuses = new StreamController();
  double transactionProgess = 0.30;
  Transaction currentTransaction;

  InterfaceManager(){
    statuses = manager.transactionUpdateStream;
  }

  Future<void> createTransaction(User from, User to, double amount ) async{
  

    if(manager.getCurrentTransaction() != null){
       statuses.add(InterfaceManagerMessage.inProgress);
      return;
    }

    if(amount == null){
       statuses.add(InterfaceManagerMessage.emptyAmountField);
       return;
    }
    
    
    await manager.createTransaction(from, to, amount);
  }

  clearTransactionProgress(){
    transactionProgess = 0.30;
  }

   updateWithAlertMessage(dynamic event){
    // show snack bar on canvas
    transactionProgess += 0.70;
    print(transactionProgess);
    if(event is InterfaceManagerMessage){
      switch(event){
        case InterfaceManagerMessage.inProgress:
          return "Unable to fulfill request. A transaction is currently in progress.";
        case InterfaceManagerMessage.emptyAmountField:
          return "The amount field must not be empty";
        default: return "";
      }
    } else {
       var time = new DateTime.now();
       switch(event){
       
        case TransactionStatus.created:
         
          return 'Transaction created at ${time.hour}:${time.minute}:${time.second}.';
         case TransactionStatus.running:
          return 'Transaction running at ${time.hour}:${time.minute}:${time.second}.';
        case TransactionStatus.finished: 
          statuses.add(InterfaceManagerMessage.clearProgressIndicator);
          return 'Transaction completed at ${time.hour}:${time.minute}:${time.second}.';

        case TransactionStatus.error: 
          return "";
        
        default:
          return "";
      }
    }
  }
}

class InterfaceSecurityManager extends InterfaceManager{

}