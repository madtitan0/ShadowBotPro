//+------------------------------------------------------------------+
//|                                                NewsFilter.mqh    |
//|                                  Copyright 2024, Clawdbot Module |
//+------------------------------------------------------------------+
#property copyright "Clawdbot Module"
#property strict

#include "Common.mqh"

class CNewsFilter
  {
private:
   bool              m_useNewsFilter;
   int               m_blockMinutesBefore;
   int               m_blockMinutesAfter;
   
   SNewsEvent        m_events[];
   int               m_eventCount;

public:
                     CNewsFilter();
                    ~CNewsFilter();

   void              Init(bool useFilter, int before, int after);
   void              AddEvent(datetime time, string desc, int importance);
   
   bool              IsNewsWindow();
   bool              IsEligibleProfit(datetime openTime, datetime closeTime);
   
   string            GetNextNewsInfo();

private:
   void              ClearExpiredEvents();
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CNewsFilter::CNewsFilter() : m_eventCount(0) {}

CNewsFilter::~CNewsFilter() {}

void CNewsFilter::Init(bool useFilter, int before, int after)
  {
   m_useNewsFilter = useFilter;
   m_blockMinutesBefore = before;
   m_blockMinutesAfter = after;
  }

void CNewsFilter::AddEvent(datetime time, string desc, int importance)
  {
   ArrayResize(m_events, m_eventCount + 1);
   m_events[m_eventCount].Time = time;
   m_events[m_eventCount].Description = desc;
   m_events[m_eventCount].Importance = importance;
   m_eventCount++;
  }

bool CNewsFilter::IsNewsWindow()
  {
   if(!m_useNewsFilter) return false;
   
   datetime now = TimeCurrent();
   for(int i=0; i<m_eventCount; i++)
     {
      // High Importance news (3) blocks trading
      if(m_events[i].Importance >= 3)
        {
         if(now >= m_events[i].Time - (m_blockMinutesBefore * 60) && 
            now <= m_events[i].Time + (m_blockMinutesAfter * 60))
           {
            return true;
           }
        }
     }
   return false;
  }

bool CNewsFilter::IsEligibleProfit(datetime openTime, datetime closeTime)
  {
   // Rule: Profit from trades opened/closed within 5 mins of news is ineligible
   for(int i=0; i<m_eventCount; i++)
     {
      if(m_events[i].Importance >= 3)
        {
         datetime newsTime = m_events[i].Time;
         if(MathAbs(openTime - newsTime) <= 300 || MathAbs(closeTime - newsTime) <= 300)
           {
            return false;
           }
        }
     }
   return true;
  }

string CNewsFilter::GetNextNewsInfo()
  {
   datetime now = TimeCurrent();
   for(int i=0; i<m_eventCount; i++)
     {
      if(m_events[i].Time > now)
        {
         return m_events[i].Description + " in " + (string)((m_events[i].Time - now)/60) + "m";
        }
     }
   return "No upcoming news";
  }
