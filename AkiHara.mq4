//+------------------------------------------------------------------+
//|                                                      AkiHara.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict

input double Entry_Lot = 0.1;

const string SellSignal = "OBJ I1 OPEN S ";
const string BuySignal = "OBJ I1 OPEN B ";
const string WinSignal = "OBJ I1 CLOSE LOSE ";
const string LoseSignal = "OBJ I1 CLOSE WIN ";
const string CloseMartinSignal = "OBJ I1 CLOSE MARTIN ";

string thisSymbol;
double minLot;
double maxLot;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  thisSymbol = Symbol();

  minLot = MarketInfo(Symbol(), MODE_MINLOT);
  maxLot = MarketInfo(Symbol(), MODE_MAXLOT);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  int signal = -1;  
  if(ObjectGetDouble(0, BuySignal + TimeToStr(Time[1]), OBJPROP_PRICE)) {
    signal = OP_BUY;
  }
  else if(ObjectGetDouble(0, SellSignal + TimeToStr(Time[1]), OBJPROP_PRICE)) {
    signal = OP_SELL;
  }
    
  for(int i = 0; i < OrdersTotal(); i++) {
    if(OrderSelect(i, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol)) {
        if(OrderType() == OP_BUY) {
          if(signal == -1) {
            bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0);
          }
        }
        else if(OrderType() == OP_SELL) {
          if(signal == -1) {
            bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0);
          }
        }
        
        return;
      }
    }
  }

  if(Entry_Lot < minLot || maxLot < Entry_Lot) {
    Print("lot size invalid, min = ", minLot, ", max = ", maxLot);
    return;
  }
  
  double atr = iATR(Symbol(), PERIOD_CURRENT, 14, 0);

  if(signal == OP_BUY) {
    int ordered = OrderSend(thisSymbol, OP_BUY, Entry_Lot, NormalizeDouble(Ask, Digits), 3, NormalizeDouble(Ask - atr, Digits), NormalizeDouble(Ask + atr, Digits));
  }
  else if(signal == OP_SELL) {
    int ordered = OrderSend(thisSymbol, OP_SELL, Entry_Lot, NormalizeDouble(Bid, Digits), 3, NormalizeDouble(Bid + atr, Digits), NormalizeDouble(Bid - atr, Digits));
  }
}
//+------------------------------------------------------------------+
