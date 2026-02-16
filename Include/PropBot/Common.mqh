//+------------------------------------------------------------------+
//|                                                       Common.mqh |
//|                                  Copyright 2024, Clawdbot Module |
//+------------------------------------------------------------------+
#property copyright "Clawdbot Module"
#property link      "https://www.google.com"
#property strict

//--- Enums
enum ENUM_ACCOUNT_MODE
  {
   MODE_CHALLENGE, // Evaluation Phase
   MODE_FUNDED     // Funded Phase
  };

enum ENUM_PHASE
  {
   PHASE_1,
   PHASE_2,
   PHASE_FUNDED
  };

enum ENUM_PROFIT_TAKE_ACTION
  {
   ACTION_NONE,
   ACTION_REDUCE_RISK,
   ACTION_STOP_TRADING,
   ACTION_HARD_STOP
  };

//--- Structs for V2
struct SPhaseStatus
  {
   double TargetPercent;
   double CurrentProfitPercent;
   bool   IsPassed;
  };

struct SNewsEvent
  {
   datetime Time;
   string   Description;
   int      Importance; // 1=Low, 2=Medium, 3=High
  };

//--- Constants
#define MAGIC_NUMBER 123456
#define TRAILING_STEP_ATR 0.5
#define MAX_SLIPPAGE 3
#define MAX_SPREAD_POINTS 50 // 5 pips
#define CONSISTENCY_THRESHOLD 0.35 // 35% Max Daily Winner Cap
#define DAILY_DD_GUARD_PERCENT 0.973 // 2.7% internal cut (before 3% prop limit)
#define TOTAL_DD_GUARD_PERCENT 0.925 // 7.5% internal cut (before 8% prop limit)
