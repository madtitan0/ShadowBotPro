//+------------------------------------------------------------------+
//|                                           Shadow_V2_Pullback.mq5 |
//|                                  Copyright 2024, Clawdbot Module |
//| Version: 2.00 (Trend-Following Pullback addition)                 |
//+------------------------------------------------------------------+
#include "Include/PropBot/Common.mqh"
input group "--- V2 Upgrades ---"
input bool   EnablePullbacks = true; // Key V2 breakthrough
input int    MaFastPeriod    = 9;
input int    MaSlowPeriod    = 21;
// Added Trend-Filter logic
