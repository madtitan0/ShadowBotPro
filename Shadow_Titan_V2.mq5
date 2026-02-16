//+------------------------------------------------------------------+
//|                                              ShadowTitanV2.mq5   |
//|                                  Copyright 2024, Clawdbot Module |
//|                                             https://www.google.com |
//+------------------------------------------------------------------+
#property copyright "Clawdbot Module"
#property version   "2.00"
#property strict

#include "Include/PropBot/Common.mqh"
#include "Include/PropBot/RiskManagerV2.mqh"
#include "Include/PropBot/SignalGenerator.mqh" // Reusing proven V1 logic
#include "Include/PropBot/TradeManagerV2.mqh"
#include "Include/PropBot/NewsFilter.mqh"

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group " --- Institutional Model --- "
input ENUM_ACCOUNT_MODE Mode = MODE_CHALLENGE; // Model: Challenge vs Funded

input group " --- Challenge Rules --- "
input double Phase1TargetPercent = 10.0;       // P1 Target (e.g. 10%)
input double Phase2TargetPercent = 5.0;        // P2 Target (e.g. 5%)

input group " --- Risk Engine V2 --- "
input double RiskPerTradePercent = 0.5;       // Standard Risk (Optimal 0.5-1.0)
input double DailyDDLimitPercent = 3.0;       // Hard Prop Limit (3.0%)
input double TotalDDLimitPercent = 8.0;       // Hard Prop Limit (8.0%)
input bool   EnableConsistencyEngine = true;   // 35% Max Winner Cap (Funded)

input group " --- News Filter --- "
input bool   UseNewsFilter = true;            // Block 5m news window?
input int    NewsBlockBefore = 5;             // Minutes before
input int    NewsBlockAfter = 5;              // Minutes after

input group " --- Strategy (Sovereign Set) --- "
input int    MaFast = 5;                      // Sovereign Fast EMA
input int    MaMedium = 13;                   // Sovereign Medium EMA
input int    MaSlow = 50;                     // Sovereign Slow EMA (Filter)
input int    RsiPeriod = 14;                  // Momentum Period

//+------------------------------------------------------------------+
//| Global Objects                                                   |
//+------------------------------------------------------------------+
CRiskManagerV2    RiskManager;
CSignalGenerator  SignalGenerator;
CTradeManagerV2   TradeManager;
CNewsFilter       NewsFilter;

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   // 1. Init Modules
   RiskManager.Init(Mode, DailyDDLimitPercent, TotalDDLimitPercent, RiskPerTradePercent);
   TradeManager.Init(_Symbol, MAGIC_NUMBER, Mode);
   NewsFilter.Init(UseNewsFilter, NewsBlockBefore, NewsBlockAfter);
   
   // 2. Strategy Init
   SignalGenerator.Init(_Symbol, PERIOD_CURRENT, 14, 10, MAX_SPREAD_POINTS);
   SignalGenerator.InitV2(true, true, 20, 2.5, RsiPeriod, MaFast, MaMedium);
   SignalGenerator.InitV3(true, PERIOD_H1, MaSlow);
   
   Print("SHADOW TITAN V2: Booted in Mode ", EnumToString(Mode));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   // 1. Heartbeat
   RiskManager.OnTick();
   TradeManager.ManageTrades();
   
   // 2. Display Dashboard
   DrawDashboard();
   
   // 3. Execution Logic
   if(!RiskManager.IsTradingAllowed() || NewsFilter.IsNewsWindow()) return;
   
   // 4. Signal Check
   ENUM_SIGNAL_TYPE signal = SignalGenerator.GetSignal();
   
   if(signal != SIGNAL_NONE && TradeManager.CountTrades() < 1)
     {
      double lot = RiskManager.GetLotSize(100, _Symbol); // Dummy SL points for size calc helper
      if(lot <= 0) return;
      
      if(signal == SIGNAL_BUY) TradeManager.OpenBuy(lot, 200, 600, "ST-V2 Buy");
      else if(signal == SIGNAL_SELL) TradeManager.OpenSell(lot, 200, 600, "ST-V2 Sell");
     }
  }

//+------------------------------------------------------------------+
//| Dashboard UI                                                     |
//+------------------------------------------------------------------+
void DrawDashboard()
  {
   string out = "🏛️ SHADOW TITAN V2 | MODE: " + EnumToString(Mode) + "\n";
   out += "------------------------------------------------\n";
   out += "Daily DD: " + DoubleToString(RiskManager.GetDailyDDPercent(), 2) + "% / 2.7% (Internal)\n";
   out += "Total DD: " + DoubleToString(RiskManager.GetTotalDDPercent(), 2) + "% / 7.5% (Internal)\n";
   
   if(Mode == MODE_FUNDED)
      out += "Consistency: " + DoubleToString(RiskManager.GetConsistencyScore()*100, 2) + "% / 35.0%\n";
   
   out += "News: " + NewsFilter.GetNextNewsInfo() + "\n";
   out += "------------------------------------------------\n";
   
   Comment(out);
  }
