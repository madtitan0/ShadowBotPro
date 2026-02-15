# 🚀 SHADOW TITAN V1: MT5 Deployment Guide

This guide ensures the **SHADOW TITAN: Hedge Fund Edition** is correctly configured for your MetaTrader 5 (MT5) environment, covering all institutional use cases.

---

## 1. MetaTrader 5 Installation
1.  **File Management**:
    *   Copy `PropBot.mq5` to your MT5 Terminal Directory: `MQL5/Experts/`
    *   Copy the entire `Include/PropBot/` folder to: `MQL5/Include/`
2.  **Compilation**:
    *   Open `PropBot.mq5` in MetaEditor.
    *   Press **F7** (Compile).
    *   Ensure 0 errors and 0 warnings are reported.

---

## 2. Institutional Deployment Modes

### 🏛️ Scenario A: Real / Funded Accounts (Stability Mode)
*Focus: Long-term survival and consistent 10-20% monthly profit with zero risk of account breach.*
*   **Asset**: XAUUSD (Gold)
*   **Timeframe**: H1
*   **Risk Settings**:
    *   `RiskPerTrade`: 0.005 (0.5%)
    *   `MaxDailyDrawdown`: 1.5%
    *   `MonthlyDrawdownLimit`: 1.95%
    *   `MonthlyProfitTarget`: 20.0%
*   **Strategy**: Default (EMA Ensemble + RSI Momentum)

### ⚔️ Scenario B: Funded Account Challenge (Aggressive Mode)
*Focus: High-velocity growth to hit challenge targets (e.g., 8-10%) in minimum time.*
*   **Asset**: XAUUSD (Gold)
*   **Timeframe**: M15 (for more signals) or H1
*   **Risk Settings**:
    *   `RiskPerTrade`: 0.01 (1.0%)
    *   `MaxDailyDrawdown`: 1.8%
    *   `MonthlyDrawdownLimit`: 1.95%
    *   `MonthlyProfitTarget`: 10.0% (Challenge Target)
*   **Note**: Once the challenge target is hit, the Titan's **Profit Lockdown** will automatically pause trading for the month/evaluation phase.

---

## 3. MT5 Strategy Tester (Backtesting)

To verify the Titan's performance on your broker's specific data:
1.  **Open Strategy Tester**: `View -> Strategy Tester`.
2.  **Select Expert**: `PropBot.ex5`.
3.  **Symbol**: `XAUUSD` (or your broker's Gold ticker).
4.  **Interval**: Every tick (Based on real ticks) - *Crucial for precision results*.
5.  **Period**: Last 3-5 Years.
6.  **Modeling**: `1 minute OHLC` or `Every tick`.

---

## 🛡️ Critical Safety Protocols
*   **VPS Mandatory**: For live and funded accounts, run the Titan on a high-speed VPS with <10ms latency to your broker.
*   **News Filter**: (Optional but Recommended) Pause trading 5 minutes before and after high-impact USD economic news events (NFP, CPI, FOMC).
*   **Global Variables**: The Titan uses `GlobalVariables` to track daily equity floors. Do not manually clear variables starting with `PropBot_`.

---

*The SHADOW TITAN is now ready for deployment. Follow the risk parameters strictly to maintain Hedge Fund Grade consistency.*
