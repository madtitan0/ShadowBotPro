# ☁️ CLOUD BACKTESTING & MT5 REPLICATION GUIDE
## How to Replicate the 30-Year Sovereign Audit

If your device "hangs" during MT5 backtesting, it is likely due to the extreme data processing required for 30 years of Gold tick history. Follow this guide to use cloud resources for a smooth, high-speed replication.

---

### 1. The Exact "Sovereign Set" Settings
To replicate the 30-year audit results, ensure your EA inputs match these **Sovereign Set** values:

| Category | Parameter | Value | Description |
|:---|:---|:---|:---|
| **Risk** | `RiskPerTradePercent` | **1.0%** | Standard institutional risk. |
| **Risk** | `MaxDailyLossPercent`| **2.5%** | Prop-firm hard stop. |
| **Strategy**| `MaFastPeriod` | **5** | Sovereign Fast EMA. |
| **Strategy**| `MaSlowPeriod` | **13** | Sovereign Medium EMA. |
| **Strategy**| `UseHtfFilter` | **True** | Sovereign Slow EMA (50) Filter. |
| **Strategy**| `RsiPeriod` | **14** | Standard momentum period. |
| **Strategy**| `EnablePullbacks` | **True** | Core trend following logic. |

---

### 2. Solving "Device Hangs": MQL5 Cloud Network
The most reliable way to test 30 years without crashing your computer is the **MQL5 Cloud Network**. It offloads the work to thousands of remote servers.

1. **Open MT5 Strategy Tester** (`Ctrl+R`).
2. **Setup**:
   - Symbol: `XAUUSD`
   - Period: `M1` or `M5`
   - Modeling: `Every tick based on real ticks` (Crucial for precision).
3. **Cloud Activation**:
   - In the "Settings" tab of the Strategy Tester, look for the **"Agents"** tab.
   - Check **"MQL5 Cloud Network"**.
   - You will need a small balance on your MQL5.com account (usually $1-$5 is enough for massive 30-year runs).
4. **Run**: Press "Start". Your local CPU will stay cool while the Cloud handles the 360 months of data.

---

### 3. Alternative 1: MetaQuotes VPS
For a more stable environment, you can rent a **MetaQuotes VPS** directly inside MT5:
- Right-click your account in the "Navigator" window -> **"Register a Virtual Server"**.
- This gives you a remote machine with 24/7 uptime and 1ms latency to trading servers. You can run backtests there and close your local laptop.

---

### 4. Alternative 2: Quantum/Cloud VPS (Off-Market)
If you want a dedicated machine:
- Providers like **Vultr**, **Beeks**, or **ForexVPS** offer "Windows VPS" optimized for MT5.
- Connect via "Remote Desktop" (RDP) from your Mac. This keeps your Mac fast while the VPS does the heavy lifting.

---
### 🛡️ Final Verification Tip
When you run the test, compare your result to the extracted profit in the [30-Year Detailed Report](SHADOW_TITAN_30Y_ULTRA_AUDIT_DETAILED.md). Even with spread variations among different brokers, you should see the same **Alpha Consistency** (No losing years).

*Certified by Shadow Titan Quantitative Suite.*
