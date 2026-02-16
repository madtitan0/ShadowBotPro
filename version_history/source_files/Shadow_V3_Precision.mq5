//+------------------------------------------------------------------+
//|                                           Shadow_V3_Precision.mq5|
//|                                  Copyright 2024, Clawdbot Module |
//| Version: 3.00 (Precision Tuning & ADX Filter)                   |
//+------------------------------------------------------------------+
#include "Include/PropBot/Common.mqh"
input group "--- V3 Precision ---"
input int    AdxPeriod     = 14; 
input double MinAdxLevel    = 25; // Volatility Filter
input bool   UseHtfFilter  = true; // H1 Structural Guard
