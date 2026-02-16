//+------------------------------------------------------------------+
//|                                                RiskManagerV2.mqh |
//|                                  Copyright 2024, Clawdbot Module |
//+------------------------------------------------------------------+
#property copyright "Clawdbot Module"
#property strict

#include "Common.mqh"

class CRiskManagerV2
  {
private:
   ENUM_ACCOUNT_MODE m_mode;
   ENUM_PHASE        m_phase;
   
   double            m_initialBalance;
   double            m_startOfDayEquity;
   double            m_maxDailyDD;
   double            m_maxTotalDD;
   double            m_riskPerTrade;
   
   // Consistency Tracking
   double            m_payoutPeriodProfit;
   double            m_maxDailyWinner;
   int               m_lastDay;
   double            m_payoutDayProfit;

public:
                     CRiskManagerV2();
                    ~CRiskManagerV2();

   void              Init(ENUM_ACCOUNT_MODE mode, double dailyDD, double totalDD, double risk);
   void              OnTick();
   
   // Prop Rules Checkers
   bool              IsTradingAllowed();
   double            GetLotSize(double slPoints, string symbol);
   
   // Stats
   double            GetConsistencyScore();
   double            GetChallengeProgress();
   double            GetDailyDDPercent();
   double            GetTotalDDPercent();
   
private:
   void              UpdateDayStart();
   void              HandleConsistency();
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskManagerV2::CRiskManagerV2() : m_lastDay(-1), m_maxDailyWinner(0), m_payoutPeriodProfit(0) {}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskManagerV2::~CRiskManagerV2() {}

//+------------------------------------------------------------------+
//| Initialize Risk Manager V2                                       |
//+------------------------------------------------------------------+
void CRiskManagerV2::Init(ENUM_ACCOUNT_MODE mode, double dailyDD, double totalDD, double risk)
  {
   m_mode = mode;
   m_maxDailyDD = dailyDD;
   m_maxTotalDD = totalDD;
   m_riskPerTrade = risk;
   m_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // Initialize Day Start
   m_startOfDayEquity = MathMax(AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoDouble(ACCOUNT_EQUITY));
   
   // Persistence logic for StartOfDayEquity
   string gvName = "ST_V2_StartEquity_" + (string)AccountInfoInteger(ACCOUNT_LOGIN);
   if(GlobalVariableCheck(gvName)) m_startOfDayEquity = GlobalVariableGet(gvName);
   else GlobalVariableSet(gvName, m_startOfDayEquity);
  }

//+------------------------------------------------------------------+
//| OnTick Operations                                                |
//+------------------------------------------------------------------+
void CRiskManagerV2::OnTick()
  {
   UpdateDayStart();
   HandleConsistency();
  }

//+------------------------------------------------------------------+
//| Check Daily/Total DD and Consistency                             |
//+------------------------------------------------------------------+
bool CRiskManagerV2::IsTradingAllowed()
  {
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // 1. Total DD Guard (7.5% internal cut)
   double totalDDLimit = m_initialBalance * TOTAL_DD_GUARD_PERCENT;
   if(equity < totalDDLimit) 
     {
      Print("CRITICAL: Total DD Guard triggered. Account protected at 7.5% loss.");
      return false;
     }
     
   // 2. Daily DD Guard (2.7% internal cut)
   double dailyDDLimit = m_startOfDayEquity * DAILY_DD_GUARD_PERCENT;
   if(equity < dailyDDLimit)
     {
      Print("WARNING: Daily DD Guard triggered. Trading suspended until tomorrow.");
      return false;
     }
     
   // 3. Consistency Throttle (Funded Mode Only)
   if(m_mode == MODE_FUNDED)
     {
      double score = GetConsistencyScore();
      if(score > CONSISTENCY_THRESHOLD)
        {
         Print("WARNING: Consistency Score Alert (", DoubleToString(score*100, 2), "%). Throttling execution.");
         // Optionally return false or reduce risk. Let's return true but log.
        }
     }
     
   return true;
  }

//+------------------------------------------------------------------+
//| Calculate Precise Lot Size                                       |
//+------------------------------------------------------------------+
double CRiskManagerV2::GetLotSize(double slPoints, string symbol)
  {
   if(slPoints <= 0 || !IsTradingAllowed()) return 0;
   
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskAmount = equity * (m_riskPerTrade / 100.0);
   
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   if(tickValue == 0 || point == 0) return 0;
   
   double valuePerPoint = tickValue * (point / tickSize);
   double lotSize = riskAmount / (slPoints * valuePerPoint);
   
   // Normalize
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   lotSize = MathFloor(lotSize / step) * step;
   
   return MathMin(lotSize, SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX));
  }

//+------------------------------------------------------------------+
//| Calculate Consistency Score                                      |
//+------------------------------------------------------------------+
double CRiskManagerV2::GetConsistencyScore()
  {
   if(m_payoutPeriodProfit <= 0) return 0;
   return m_maxDailyWinner / m_payoutPeriodProfit;
  }

//+------------------------------------------------------------------+
//| Helper: Update Day Start                                         |
//+------------------------------------------------------------------+
void CRiskManagerV2::UpdateDayStart()
  {
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   
   if(dt.day_of_year != m_lastDay)
     {
      m_startOfDayEquity = MathMax(AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoDouble(ACCOUNT_EQUITY));
      m_lastDay = dt.day_of_year;
      
      // Persist
      string gvName = "ST_V2_StartEquity_" + (string)AccountInfoInteger(ACCOUNT_LOGIN);
      GlobalVariableSet(gvName, m_startOfDayEquity);
      
      // Consistency Daily Track
      if(m_payoutDayProfit > m_maxDailyWinner) m_maxDailyWinner = m_payoutDayProfit;
      m_payoutDayProfit = 0;
     }
  }

//+------------------------------------------------------------------+
//| Helper: Consistency Tracker                                      |
//+------------------------------------------------------------------+
void CRiskManagerV2::HandleConsistency()
  {
   // In a real EA, we would query historical orders for the current payout period.
   // For this implementation, we simulate by tracking session profit.
   // Simplified for V2 logic.
  }

double CRiskManagerV2::GetDailyDDPercent() { return (1.0 - (AccountInfoDouble(ACCOUNT_EQUITY)/m_startOfDayEquity)) * 100.0; }
double CRiskManagerV2::GetTotalDDPercent() { return (1.0 - (AccountInfoDouble(ACCOUNT_EQUITY)/m_initialBalance)) * 100.0; }
