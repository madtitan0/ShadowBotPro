//+------------------------------------------------------------------+
//|                                                TradeManagerV2.mqh|
//|                                  Copyright 2024, Clawdbot Module |
//+------------------------------------------------------------------+
#property copyright "Clawdbot Module"
#property strict

#include <Trade/Trade.mqh>
#include "Common.mqh"

class CTradeManagerV2
  {
private:
   CTrade            m_trade;
   string            m_symbol;
   ulong             m_magic;
   ENUM_ACCOUNT_MODE m_mode;
   
public:
                     CTradeManagerV2();
                    ~CTradeManagerV2();

   void              Init(string symbol, ulong magic, ENUM_ACCOUNT_MODE mode);
   
   bool              OpenBuy(double volume, double slPoints, double tpPoints, string comment="");
   bool              OpenSell(double volume, double slPoints, double tpPoints, string comment="");
   
   void              ManageTrades(); 
   void              EnforceMandatorySL();
   void              PartialClose(double percent);
   void              CloseAll();
   
   int               CountTrades();
  };

//+------------------------------------------------------------------+
//| Constructor & Init                                               |
//+------------------------------------------------------------------+
CTradeManagerV2::CTradeManagerV2() : m_symbol(_Symbol), m_magic(MAGIC_NUMBER), m_mode(MODE_CHALLENGE) {}
CTradeManagerV2::~CTradeManagerV2() {}

void CTradeManagerV2::Init(string symbol, ulong magic, ENUM_ACCOUNT_MODE mode)
  {
   m_symbol = symbol;
   m_magic = magic;
   m_mode = mode;
   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(symbol);
  }

//+------------------------------------------------------------------+
//| Open Buy/Sell with Hard SL enforcement                           |
//+------------------------------------------------------------------+
bool CTradeManagerV2::OpenBuy(double volume, double slPoints, double tpPoints, string comment="")
  {
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   
   double sl = (slPoints > 0) ? ask - slPoints * point : 0;
   double tp = (tpPoints > 0) ? ask + tpPoints * point : 0;
   
   // In Funded mode, SL is mandatory
   if(m_mode == MODE_FUNDED && sl <= 0)
     {
      Print("FUNDED ERROR: Mandatory SL missing. Request blocked.");
      return false;
     }
     
   return m_trade.Buy(volume, m_symbol, ask, sl, tp, comment);
  }

bool CTradeManagerV2::OpenSell(double volume, double slPoints, double tpPoints, string comment="")
  {
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   
   double sl = (slPoints > 0) ? bid + slPoints * point : 0;
   double tp = (tpPoints > 0) ? bid - tpPoints * point : 0;
   
   if(m_mode == MODE_FUNDED && sl <= 0)
     {
      Print("FUNDED ERROR: Mandatory SL missing. Request blocked.");
      return false;
     }
     
   return m_trade.Sell(volume, m_symbol, bid, sl, tp, comment);
  }

//+------------------------------------------------------------------+
//| Manage: Trail & Enforce SL                                       |
//+------------------------------------------------------------------+
void CTradeManagerV2::ManageTrades()
  {
   EnforceMandatorySL();
  }

void CTradeManagerV2::EnforceMandatorySL()
  {
   if(m_mode != MODE_FUNDED) return;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetInteger(POSITION_MAGIC) == m_magic)
           {
            if(PositionGetDouble(POSITION_SL) <= 0)
              {
               Print("CRITICAL: Funded Position ", ticket, " has no SL. Closing immediately.");
               m_trade.PositionClose(ticket);
              }
           }
        }
     }
  }

void CTradeManagerV2::PartialClose(double percent)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetInteger(POSITION_MAGIC) == m_magic)
           {
            double vol = PositionGetDouble(POSITION_VOLUME);
            m_trade.PositionClosePartial(ticket, vol * percent);
           }
        }
     }
  }

void CTradeManagerV2::CloseAll()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetInteger(POSITION_MAGIC) == m_magic)
           {
            m_trade.PositionClose(ticket);
           }
        }
     }
  }

int CTradeManagerV2::CountTrades()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetInteger(POSITION_MAGIC) == m_magic) count++;
        }
     }
   return count;
  }
