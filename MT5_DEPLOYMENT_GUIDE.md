# SHADOW TITAN V2: PROP-FIRM DEPLOYMENT GUIDE
## 🏛️ Institutional Intelligence & Execution (V2.0)

Shadow Titan V2 is a dual-model Expert Advisor designed to navigate both the **Challenge Phase** and the **Funded Phase** of institutional prop-firms (Funding Pips, FTMO, etc.).

---

### 1. Model Selection
Switch between models using the `Mode` input at the top level:
- **MODE_CHALLENGE**: Used for Phase 1 (10% target) and Phase 2 (5% target). Risk is optimized for rapid extraction while respecting the 3% daily DD cap.
- **MODE_FUNDED**: Enforces mandatory Stop Loss (SL) and monitors Consistency (35% winner cap).

### 2. Core V2 Settings (Sovereign Set)
These values are synchronized with the 30-Year Institutional Audit.

| Category | Input | Value | Description |
|:---|:---|:---|:---|
| **Risk** | `RiskPerTradePercent` | **0.5% - 1.0%** | Standard risk per trade. |
| **Risk** | `DailyDDLimitPercent` | **3.0%** | EA cuts at **2.7%** internal guard. |
| **Risk** | `TotalDDLimitPercent` | **8.0%** | EA cuts at **7.5%** internal guard. |
| **Strategy** | `MaFast / Medium` | **5 / 13** | Sovereign Trend detection. |
| **Strategy** | `MaSlow (Filter)` | **50** | Sovereign H1 Structural Filter. |

### 3. V2 Intelligence Modules
#### 🎲 Consistency Engine (Funded Only)
The EA tracks your largest winning day. If a single day contributes more than **35%** of your total profit, the dashboard will warn you to smooth your equity curve to meet prop payout requirements.

#### 🌪️ News Guard
Set `UseNewsFilter = true`. The EA will automatically block trading 5 minutes before and after high-impact news events to ensure all profits are "eligible" according to funded account rules.

#### 🛡️ Internal Guards
V2 does not wait for the prop firm to blow your account. It has internal hard-stops at **2.7% Daily** and **7.5% Total** drawdown to account for slippage and protect the underlying capital.

---

### 4. Installation
1. Move `ShadowTitanV2.mq5` to your MT5 `MQL5/Experts/` folder.
2. Ensure the `Include/PropBot/` folder contains the new `V2` modules (`RiskManagerV2.mqh`, `TradeManagerV2.mqh`, `NewsFilter.mqh`).
3. Compile in MetaEditor (`F7`).

---
*Verified by Shadow Titan Quantitative Suite.*
*Disclaimer: Trading involves risk. Use the MQL5 Cloud Network for 30-year backtests.*
