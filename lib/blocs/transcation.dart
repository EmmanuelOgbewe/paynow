import 'dart:async';

class User{
  final String uid;
  final String name; 
  double _balance;
  User(this.uid, this.name, this._balance);

  void setBalance(double balance){
    _balance = balance;
  }

  double getBalance(){
    return _balance;
  }
} 

/**
 * Provides statuses for a transaction
 */
enum TransactionStatus {
  error,
  created,
  running, 
  inProgress,
  stopped, 
  paused,
  finished
}

enum TranscationErrorReason {
  insufficientBalance, 
  serverError
}

class Transaction 
{
  final String _id; 
  final User _from;
  final User _to;
  final double _amount;
  String _time;

  TransactionStatus status = TransactionStatus.created;

  Transaction(this._from, this._to, this._amount, this._id);

  String getId () {
    return _id;
  }
  User getFrom () {
    return _from;
  }
  User getTo () {
    return _to;
  }

  setTime(DateTime time){
    _time = '${time.day} ${time.hour}:${time.minute}:${time.second}';
  }

  String getTime(){
    return _time;
  }

  TransactionStatus getTransactionStatus(){
    return status;
  }

  double getAmount(){
    return _amount;
  }

}

class TransactionManager {

  Map<String,Transaction> _transactions = new Map<String,Transaction>();
  List<Transaction> _transactionQueue = new List<Transaction>();


  StreamController transactionUpdateStream =  StreamController();

  int _transactionCount = 0;

  Future<bool> createTransaction(User from, User to, double amount) {

    Transaction tr = new Transaction(from, to, amount,  _transactionCount.toString());
    _transactions['id'] = tr;
    _transactionQueue.insert(0, tr);
     
    _transactionCount += 1;

    changeTransactionStatus(TransactionStatus.running, tr);
    return Future.delayed(new Duration(seconds: 4), (){

      to.setBalance(
        to._balance + amount
      );

      from.setBalance(from._balance - amount);

      tr.setTime(new DateTime.now());
      changeTransactionStatus(TransactionStatus.finished, tr);
      // pop current transaction
      _transactionQueue.removeAt(0);
      return true;
    });
  }
  
  Transaction getCurrentTransaction(){
    if(_transactionQueue.isEmpty == false){
      return _transactionQueue.first;
    }
      return null;
  }

  void changeTransactionStatus(TransactionStatus to, Transaction tr){
    tr.status = to;

    // update stream
    transactionUpdateStream.add(tr.status);
    
    print('Transaction Status : ${tr.status}') ;
  }


}



