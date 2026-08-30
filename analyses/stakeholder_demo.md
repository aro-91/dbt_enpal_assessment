# Sales funnel insights

What the delivered report shows, plus four more views worth building. Written
for a reader who will not open the SQL.

## Monthly funnel

**How many deals moved into each stage of the pipeline each month?**

| Month | Lead Generation | Qualified Lead | Sales Call 1 | Needs Assessment | Sales Call 2 | Proposal/Quote Prep | Negotiation | Closing | Implementation | Follow-up | Renewal |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2024-01 | 30 | 6 | 77 | 1 | 67 | 1 | 0 | 0 | 0 | 0 | 0 |
| 2024-02 | 194 | 92 | 64 | 49 | 59 | 31 | 20 | 11 | 3 | 2 | 2 |
| 2024-03 | 199 | 232 | 54 | 198 | 75 | 133 | 88 | 55 | 36 | 19 | 7 |
| 2024-04 | 230 | 208 | 71 | 196 | 58 | 185 | 163 | 128 | 83 | 52 | 23 |
| 2024-05 | 248 | 238 | 61 | 226 | 65 | 213 | 185 | 153 | 108 | 78 | 25 |
| 2024-06 | 244 | 245 | 64 | 247 | 66 | 240 | 206 | 181 | 138 | 98 | 42 |
| 2024-07 | 266 | 254 | 88 | 240 | 65 | 221 | 214 | 193 | 152 | 86 | 48 |
| 2024-08 | 239 | 256 | 57 | 257 | 72 | 244 | 212 | 179 | 136 | 105 | 37 |
| 2024-09 | 208 | 222 | 32 | 210 | 33 | 224 | 224 | 157 | 125 | 78 | 43 |
| 2024-10 | 119 | 173 | – | 207 | – | 207 | 186 | 167 | 129 | 79 | 36 |
| 2024-11 | 18 | 60 | – | 100 | – | 118 | 125 | 115 | 97 | 73 | 31 |
| 2024-12 | 0 | 4 | – | 18 | – | 40 | 57 | 63 | 54 | 34 | 19 |
| 2025-01 | 0 | 0 | – | 2 | – | 5 | 13 | 19 | 17 | 16 | 10 |
| 2025-02 | 0 | 0 | – | 0 | – | 0 | 0 | 3 | 3 | 3 | 1 |

Read this as stage entries, not new business. Each number counts deals that
moved into that stage during the month, which is what Pipedrive's Deal Progress
report measures. New deals are a separate figure: creation held roughly flat at
240 a month from January to August 2024, then stopped in September.

That distinction explains the shape. Early stages fall away from October because
no new deals arrive after September, so nothing is left to enter them. Later
stages keep posting numbers into 2025 as the team works deals already in the
pipeline. The apparent decline at the top of the funnel is the edge of the data
window, so treat any read on demand as unsupported until the export covers a
longer period.

## Four more views

Each answers a question a head of sales asks next.

### Of the deals we bring in this month, what share will we close?

| Cohort | Lead Gen | Qualified Lead | Needs Assessment | Proposal/Quote | Negotiation | Closing | Implementation | Follow-up | Renewal |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2024-01 | 100.0 | 100.0 | 96.4 | 92.3 | 83.0 | 69.2 | 51.0 | 36.4 | 14.2 |
| 2024-02 | 100.0 | 100.0 | 99.5 | 94.6 | 87.3 | 75.1 | 55.6 | 38.5 | 19.5 |
| 2024-03 | 100.0 | 100.0 | 99.2 | 95.0 | 88.4 | 77.3 | 59.1 | 41.3 | 17.8 |
| 2024-04 | 100.0 | 98.8  | 96.7 | 93.4 | 85.7 | 73.8 | 55.3 | 36.9 | 13.5 |
| 2024-05 | 100.0 | 100.0 | 98.5 | 93.5 | 84.7 | 70.6 | 54.6 | 35.5 | 19.1 |
| 2024-06 | 100.0 | 99.6  | 96.8 | 91.9 | 82.7 | 67.7 | 54.0 | 34.7 | 16.1 |
| 2024-07 | 100.0 | 99.6  | 97.4 | 94.0 | 86.3 | 68.7 | 54.1 | 36.1 | 18.0 |
| 2024-08 | 100.0 | 100.0 | 98.7 | 93.0 | 84.6 | 71.4 | 51.5 | 33.9 | 13.2 |
| 2024-09 | 100.0 | 100.0 | 96.7 | 91.3 | 77.2 | 67.4 | 52.2 | 29.3 | 14.1 |

This turns "we generated 200 leads" into an expected number of renewals, which
makes it a forecasting input rather than a status update. It also locates the
leak. Every cohort loses more than half its surviving deals between Closing and
Renewal, the largest drop in the funnel, which is where a renewal or
customer-success push would pay back fastest.

### Where are deals getting stuck, and for how long?

Average days spent in each stage, by month entered.

| Month | Lead Gen | Qualified Lead | Needs Assessment | Proposal/Quote | Negotiation | Closing | Implementation | Follow-up |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 2024-01 | 14.7 | 16.8 | 0.0  | 29.0 |     |     |     |     |
| 2024-02 | 16.2 | 11.5 | 9.5  | 8.7  | 8.3 | 5.0 | 4.0 | 0.0 |
| 2024-03 | 14.9 | 10.5 | 10.8 | 8.1  | 8.1 | 7.2 | 2.5 | 1.9 |
| 2024-04 | 15.2 | 11.8 | 10.0 | 7.4  | 6.9 | 5.6 | 5.6 | 3.6 |
| 2024-05 | 15.2 | 11.9 | 9.8  | 8.8  | 7.9 | 5.8 | 3.9 | 3.8 |
| 2024-06 | 15.4 | 10.6 | 10.0 | 8.5  | 6.8 | 5.9 | 4.3 | 5.0 |
| 2024-07 | 15.2 | 11.8 | 11.3 | 8.4  | 5.6 | 5.6 | 6.7 | 3.4 |
| 2024-08 | 16.6 | 11.3 | 10.3 | 9.6  | 5.6 | 5.0 | 4.7 | 6.0 |
| 2024-09 | 14.7 | 11.9 | 8.9  | 8.6  | 8.0 | 5.8 | 4.9 | 3.9 |
| 2024-10 | 16.5 | 11.2 | 9.8  | 8.4  | 7.4 | 5.9 | 5.8 | 3.5 |
| 2024-11 | 19.4 | 11.7 | 10.9 | 8.4  | 6.9 | 5.7 | 3.6 | 3.5 |
| 2024-12 |      | 11.3 | 12.7 | 9.8  | 6.7 | 6.0 | 5.3 | 3.0 |
| 2025-01 |      |      | 11.5 | 6.8  | 7.1 | 1.4 | 5.5 | 1.3 |
| 2025-02 |      |      |      |      |     | 0.0 | 0.0 | 0.0 |

Lead Generation takes longest of any stage, and every later stage moves faster
than the one before it. Anyone trying to shorten the sales cycle should start
with how quickly a lead gets qualified, not with negotiation or closing, which
already run efficiently. Deals still open in a stage are excluded, so these
averages describe deals that moved on.

### How is pipeline distributed across the sales team?

Top 10 reps by total active deals.

| Owner | Total | Lead Gen | Qualified Lead | Needs Assessment | Proposal/Quote | Negotiation | Closing | Implementation | Follow-up | Renewal |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Michael Smith | 38 | 4 | 4 | 4 | 3 | 3 | 2 | 2 | 1 | 1 |
| Robert Combs | 37 | 6 | 6 | 6 | 6 | 4 | 3 | 3 | 2 | 1 |
| Adam King | 35 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 1 | 1 |
| Shawn Brock | 33 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 3 | 3 |
| Matthew Murray | 33 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 2 |
| Ronald Ryan | 33 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 2 |
| Caleb Fletcher | 33 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 1 |
| Michelle Smith | 33 | 5 | 5 | 5 | 4 | 4 | 4 | 4 | 1 | 1 |
| Jasmin Jones | 32 | 5 | 5 | 5 | 5 | 5 | 4 | 1 | 1 | 1 |
| Tanya Spears | 31 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 2 | 2 |

Two uses: checking whether workload sits evenly across the team, which it does
here even at the top, and finding a rep whose stage-to-stage pattern beats the
rest so their approach can be taught.

### Why are we losing deals, and at which stage?

| Stage | Customer Not Ready | Pricing Issues | Unreachable Customer | Product Mismatch | Duplicate Entry |
|---|---:|---:|---:|---:|---:|
| Lead Generation | – | 1 | – | 3 | 1 |
| Qualified Lead | 7 | 7 | 11 | 7 | 7 |
| Needs Assessment | 17 | 13 | 22 | 18 | 19 |
| Proposal/Quote Preparation | 29 | 36 | 44 | 36 | 24 |
| Negotiation | 52 | 53 | 53 | 59 | 52 |
| Closing | 71 | 64 | 73 | 66 | 70 |
| Implementation/Onboarding | 62 | 67 | 77 | 85 | 67 |
| Follow-up/Customer Success | 80 | 86 | 75 | 71 | 88 |
| Renewal/Expansion | 63 | 74 | 67 | 72 | 49 |

With reliable loss reasons, this is the report that targets fixes precisely.
Pricing objections concentrated in Negotiation would justify sales-enablement
work on value messaging; "Unreachable Customer" losses early on would point at
lead quality or outreach cadence.

**Read this one as a shape, not a finding.** In this sample every deal carries a
loss reason and the five reasons split evenly within every stage, so the numbers
say nothing yet about why deals are actually lost.
