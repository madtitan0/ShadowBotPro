//+------------------------------------------------------------------+
//|                                           Shadow_V4_Robust.mq5   |
//|                                  Copyright 2024, Clawdbot Module |
//| Version: 4.00 (Monte Carlo Robustness Final)                    |
//+------------------------------------------------------------------+
#include "Include/PropBot/Common.mqh"
input group "--- V4 Robustness ---"
input bool   EnableNewsFilter = true; // Early news guard implementation
input double SlippageAllowance = 3.0; // Execution Sensitivity control
// Integrated randomized order execution for MC survival testing.
