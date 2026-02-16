//+------------------------------------------------------------------+
//|                                           Shadow_V3_1_Scaling.mq5|
//|                                  Copyright 2024, Clawdbot Module |
//| Version: 3.10 (Risk Scaling & Fortune Guard)                    |
//+------------------------------------------------------------------+
#include "Include/PropBot/Common.mqh"
input group "--- V3.1 Fortune Scaler ---"
input double BaseRiskPercent = 0.75;
input double RiskModifier_DD0_5 = 1.0;  // Full risk
input double RiskModifier_DD1_5 = 0.33; // Aggressive reduction
// Dynamic Lot Sizing based on equity curves.
