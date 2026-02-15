# SHADOW TITAN V1: MT5 DEPLOYMENT & PROP-FIRM GUIDE
## 🏛️ Institutional Setup & Execution

The Shadow Titan V1 is a high-precision trend-following sniper designed for Gold (XAUUSD). This guide details how to deploy the Expert Advisor (EA) for Prop-Firms, Funded Accounts, and Private Wealth management.

---

### 1. Installation
1. **Directory Structure**: 
   - Place `PropBot.mq5` in your MT5 `MQL5/Experts/` folder.
   - Place the `Include/PropBot` directory in `MQL5/Include/`.
2. **Compile**: Open MetaEditor, open `PropBot.mq5`, and press `F7` (Compile). Ensure 0 errors.

### 2. Recommended Settings (XAUUSD)
The following inputs align with the **Sovereign Set** verified in the 30-Year Ultra-Audit.

| Input Parameter | Value | Description |
|:---|:---|:---|
| **Timeframe** | M1 or M5 | Recommended for sniper entries. |
| **Risk Per Trade** | 0.5% - 1.0% | Default for funded account preservation. |
| **Max Daily Loss** | 2.5% | Strict prop-firm hard-stop. |
| **ATR Multiplier (SL)** | 1.0 | Volatility-adjusted protective stop. |
| **ATR Multiplier (TP)** | 3.0 - 5.0 | High reward-to-risk ratio. |
| **EMA Triple Filter** | 5 / 13 / 50 | Structural trend alignment. |
| **RSI Entry Filter** | 25 / 75 | Momentum exhaustion zones. |

### 3. Prop-Firm Compliance
Shadow Titan includes a built-in **RiskManager** specifically tuned for firm mandates:
- **Daily Equity Guard**: The EA monitors floating equity. If the 2.5% loss threshold is reached, all positions are closed and trading is disabled for the day.
- **News Filter**: Set `UseNewsFilter = true` to avoid execution during high-impact volatility (CPI/FOMC).
- **Hard-Stop SL**: Every trade is opened with a hard Stop Loss. No martingale or grid logic is used.

### 4. Running a Backtest in MT5
1. Open the **Strategy Tester** (`Ctrl+R`).
2. Select `PropBot.ex5`.
3. Symbol: `XAUUSD` or `GOLD`.
4. Period: `Every Tick based on Real Ticks` (Required for precision).
5. Modeling: `1 Minute OHLC` or `Every Tick`.
6. Run the test and verify that the results align with the `INSTITUTIONAL_30Y_AUDIT.md`.

### 5. Deployment on Own Funds
For private accounts where drawdown limits are more flexible, you may increase `Risk Per Trade` to 1.5%. However, for institutional capital, the 1.0% risk cap is strictly recommended to maintain the **Structural Sniper** edge without over-leveraging.

---
*Verified by Alpha-Generation Protocol.*
*Disclaimer: Trading involves significant risk. Ensure you test in a demo environment before live deployment.*
