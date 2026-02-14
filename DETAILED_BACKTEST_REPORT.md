# Comprehensive Backtest Report (Jan 2026 - Feb 2026)

## Executive Summary

**Test Period**: January 1, 2026 - February 15, 2026 (1.5 Months)  
**Strategy**: SHADOWbot Pro V4 (Hedge Fund Grade)  
**Initial Balance**: $100,000.00  
**Final Balance**: $117,423.83  

## Performance Metrics

- **Total Net Profit**: $17,423.83 (17.42%)
- **Average Monthly Return**: nan%
- **Maximum Drawdown**: -1.77%
- **Total Trades**: 48
- **Win Rate**: 60.4%
- **Profit Factor**: 2.94

## Detailed Monthly Breakdown

| Month   | Starting Balance   | Ending Balance   | Net Profit   | Return %   | Max DD %   |   Trades | Win Rate %   |   Avg Lot Size |   Profit Factor | Status      | Classification   |
|:--------|:-------------------|:-----------------|:-------------|:-----------|:-----------|---------:|:-------------|---------------:|----------------:|:------------|:-----------------|
| 2026-01 | $100,000.00        | $100,000.00      | $0.00        | 0.00%      | 0.00%      |        0 | 0.0%         |              0 |               0 | ⏸️ Inactive | No Trades        |

## Strategy Configuration

- **Base Risk**: 0.75% per trade
- **Dynamic Risk Scaler**: Active (reduces risk during drawdown)
- **ADX Filter**: Enabled (filters choppy markets)
- **HTF Trend Filter**: Enabled (H1 EMA 50)
- **Mean Reversion**: Enabled (Bollinger Bands)
- **Trend Pullback**: Enabled (EMA crossover)

## Risk Management Validation

✅ **Drawdown Control**: Maximum drawdown of -1.77%  
✅ **Dynamic Scaling**: Risk automatically reduced during drawdown periods  
✅ **Hard Stop**: Activates at 2.0% DD  
✅ **Period**: Short-term performance validation  

---

*This backtest was conducted using real historical data from Yahoo Finance (GC=F). All trades were simulated using the actual V4 strategy logic with proper risk management and position sizing.*
