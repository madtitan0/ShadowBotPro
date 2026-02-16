//+------------------------------------------------------------------+
//|                                           Shadow_V1_Base.mq5     |
//|                                  Copyright 2024, Clawdbot Module |
//| Version: 1.00 (Initial Mean Reversion Alpha)                     |
//+------------------------------------------------------------------+
#include "Include/PropBot/Common.mqh"
#include "Include/PropBot/RiskManager.mqh"
#include "Include/PropBot/SignalGenerator.mqh"
#include "Include/PropBot/TradeManager.mqh"

input group "--- Risk ---"
input double RiskPerTrade = 2.0; // Early high-risk setting

input group "--- V1 Strategy (Mean Reversion) ---"
input bool   EnableMeanReversion = true;
input bool   EnablePullbacks     = false;
input double BollingerDev        = 2.0;
input int    RsiPeriod           = 14;

// Rest of core logic simplified for historical reference...
