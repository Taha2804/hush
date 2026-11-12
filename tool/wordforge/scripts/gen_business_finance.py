#!/usr/bin/env python3
"""
Business & Finance Word Pack Generator for Hushbug WordForge.

Creates a WordPack with ~100 high-quality business/finance terms using template-based generation.
No LLM required - uses curated templates for definitions, hints, and imposters.

Each word has:
- word: business/finance term
- category: "business_finance"
- subcategory: "Investing", "Banking", "Startup", "Corporate", "Accounting", "Economics", "Crypto", "Real Estate"
- difficulty: distributed roughly 40/40/20 (easy/medium/hard)
- description: one neutral sentence (8-18 words) defining the term
- 6 hints per difficulty level (easy/medium/hard)
- 3 imposter alternatives per difficulty level
- tags: relevant tags
- is_adult: false
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).parent.parent))

from wordforge.database.models import (
    WordDifficulty,
    WordPack,
    WordRecord,
    PackMeta,
    Hint,
    ImposterWord,
)


# =============================================================================
# WORD DEFINITIONS - ~100 words across 8 subcategories
# Target distribution: ~40 easy, ~40 medium, ~20 hard
# =============================================================================

BUSINESS_FINANCE_WORDS = [
    # INVESTING (14 words: 5 easy, 5 medium, 4 hard)
    {"word": "Stock", "subcategory": "Investing", "difficulty": "easy",
     "description": "A share representing ownership in a publicly traded company.",
     "tags": ["equity", "market", "ownership"]},
    {"word": "Bond", "subcategory": "Investing", "difficulty": "easy",
     "description": "A fixed-income loan to a government or corporation paying interest.",
     "tags": ["fixed-income", "debt", "interest"]},
    {"word": "Dividend", "subcategory": "Investing", "difficulty": "easy",
     "description": "A cash payment distributed to shareholders from company profits.",
     "tags": ["income", "shareholder", "profit"]},
    {"word": "Portfolio", "subcategory": "Investing", "difficulty": "easy",
     "description": "A collection of financial assets held by an investor.",
     "tags": ["collection", "assets", "diversification"]},
    {"word": "Bull Market", "subcategory": "Investing", "difficulty": "easy",
     "description": "A sustained period of rising stock prices and investor optimism.",
     "tags": ["rising", "optimism", "trend"]},
    {"word": "ETF", "subcategory": "Investing", "difficulty": "medium",
     "description": "An exchange-traded fund tracking an index or sector.",
     "tags": ["fund", "exchange", "index"]},
    {"word": "Mutual Fund", "subcategory": "Investing", "difficulty": "medium",
     "description": "A pooled investment vehicle managed by professionals holding diversified securities.",
     "tags": ["pooled", "managed", "diversified"]},
    {"word": "Asset Allocation", "subcategory": "Investing", "difficulty": "medium",
     "description": "The strategy of dividing investments across different asset classes.",
     "tags": ["strategy", "diversification", "risk"]},
    {"word": "Bear Market", "subcategory": "Investing", "difficulty": "medium",
     "description": "A prolonged period of declining stock prices and widespread pessimism.",
     "tags": ["declining", "pessimism", "trend"]},
    {"word": "Market Cap", "subcategory": "Investing", "difficulty": "medium",
     "description": "The total market value of a company's outstanding shares.",
     "tags": ["valuation", "shares", "total"]},
    {"word": "P/E Ratio", "subcategory": "Investing", "difficulty": "hard",
     "description": "A valuation metric comparing share price to earnings per share.",
     "tags": ["valuation", "earnings", "multiple"]},
    {"word": "Hedge Fund", "subcategory": "Investing", "difficulty": "hard",
     "description": "A private investment partnership using aggressive strategies for accredited investors.",
     "tags": ["private", "aggressive", "accredited"]},
    {"word": "Options", "subcategory": "Investing", "difficulty": "hard",
     "description": "Contracts giving the right to buy or sell an asset at a set price.",
     "tags": ["contract", "right", "derivative"]},
    {"word": "REIT", "subcategory": "Investing", "difficulty": "hard",
     "description": "A real estate investment trust owning income-producing properties.",
     "tags": ["real-estate", "trust", "income"]},

    # BANKING (12 words: 4 easy, 4 medium, 4 hard)
    {"word": "Checking Account", "subcategory": "Banking", "difficulty": "easy",
     "description": "A bank account for daily transactions with easy deposit and withdrawal access.",
     "tags": ["daily", "transactions", "access"]},
    {"word": "Savings Account", "subcategory": "Banking", "difficulty": "easy",
     "description": "A deposit account earning modest interest for short-term money storage.",
     "tags": ["deposit", "interest", "storage"]},
    {"word": "Interest Rate", "subcategory": "Banking", "difficulty": "easy",
     "description": "The percentage charged on loans or paid on deposits over time.",
     "tags": ["percentage", "loans", "deposits"]},
    {"word": "Loan", "subcategory": "Banking", "difficulty": "easy",
     "description": "Money borrowed from a lender that must be repaid with interest.",
     "tags": ["borrowed", "repayment", "interest"]},
    {"word": "Mortgage", "subcategory": "Banking", "difficulty": "medium",
     "description": "A long-term loan secured by real estate property as collateral.",
     "tags": ["secured", "property", "long-term"]},
    {"word": "Credit Score", "subcategory": "Banking", "difficulty": "medium",
     "description": "A numerical rating of creditworthiness based on borrowing history.",
     "tags": ["rating", "creditworthiness", "history"]},
    {"word": "Collateral", "subcategory": "Banking", "difficulty": "medium",
     "description": "An asset pledged as security for repayment of a loan.",
     "tags": ["security", "asset", "pledge"]},
    {"word": "Overdraft", "subcategory": "Banking", "difficulty": "medium",
     "description": "Withdrawing more money than available, creating a negative balance.",
     "tags": ["negative", "balance", "withdrawal"]},
    {"word": "Wire Transfer", "subcategory": "Banking", "difficulty": "hard",
     "description": "Electronic movement of funds between bank accounts domestically or internationally.",
     "tags": ["electronic", "funds", "transfer"]},
    {"word": "Certificate of Deposit", "subcategory": "Banking", "difficulty": "hard",
     "description": "A time deposit with a fixed term and higher interest rate.",
     "tags": ["time-deposit", "fixed-term", "higher-rate"]},
    {"word": "Prime Rate", "subcategory": "Banking", "difficulty": "hard",
     "description": "The interest rate banks charge their most creditworthy corporate customers.",
     "tags": ["benchmark", "corporate", "creditworthy"]},
    {"word": "Quantitative Easing", "subcategory": "Banking", "difficulty": "hard",
     "description": "Central bank asset purchases to increase money supply and stimulate the economy.",
     "tags": ["central-bank", "asset-purchase", "stimulus"]},

    # STARTUP (14 words: 5 easy, 5 medium, 4 hard)
    {"word": "Startup", "subcategory": "Startup", "difficulty": "easy",
     "description": "A newly founded company designed to scale rapidly with innovative products.",
     "tags": ["new", "scalable", "innovative"]},
    {"word": "Angel Investor", "subcategory": "Startup", "difficulty": "easy",
     "description": "A wealthy individual providing capital to startups in exchange for equity.",
     "tags": ["individual", "capital", "equity"]},
    {"word": "Pitch Deck", "subcategory": "Startup", "difficulty": "easy",
     "description": "A brief presentation used to persuade investors to fund a business.",
     "tags": ["presentation", "investors", "funding"]},
    {"word": "Unicorn", "subcategory": "Startup", "difficulty": "easy",
     "description": "A privately held company valued at over one billion dollars.",
     "tags": ["private", "billion-dollar", "valuation"]},
    {"word": "IPO", "subcategory": "Startup", "difficulty": "easy",
     "description": "Initial public offering when a private company first sells shares to the public.",
     "tags": ["public", "shares", "first-time"]},
    {"word": "Venture Capital", "subcategory": "Startup", "difficulty": "medium",
     "description": "Private equity financing for high-growth early-stage companies.",
     "tags": ["private-equity", "high-growth", "early-stage"]},
    {"word": "Seed Round", "subcategory": "Startup", "difficulty": "medium",
     "description": "The first official equity funding stage for a startup company.",
     "tags": ["first", "equity", "funding"]},
    {"word": "Series A", "subcategory": "Startup", "difficulty": "medium",
     "description": "The first significant venture capital round after seed funding.",
     "tags": ["significant", "venture-capital", "round"]},
    {"word": "Valuation", "subcategory": "Startup", "difficulty": "medium",
     "description": "The process of determining the current worth of a company.",
     "tags": ["worth", "company", "process"]},
    {"word": "Exit", "subcategory": "Startup", "difficulty": "medium",
     "description": "An event where investors sell their stake for profit, such as IPO or acquisition.",
     "tags": ["sell", "stake", "profit"]},
    {"word": "Term Sheet", "subcategory": "Startup", "difficulty": "hard",
     "description": "A non-binding document outlining basic conditions of an investment deal.",
     "tags": ["non-binding", "conditions", "investment"]},
    {"word": "Cap Table", "subcategory": "Startup", "difficulty": "hard",
     "description": "A spreadsheet showing ownership stakes, shares, and dilution over time.",
     "tags": ["ownership", "shares", "dilution"]},
    {"word": "Burn Rate", "subcategory": "Startup", "difficulty": "hard",
     "description": "The pace at which a startup spends its venture capital before profitability.",
     "tags": ["spending", "capital", "profitability"]},
    {"word": "Runway", "subcategory": "Startup", "difficulty": "hard",
     "description": "The number of months a startup can operate before running out of cash.",
     "tags": ["months", "cash", "operate"]},

    # CORPORATE (13 words: 4 easy, 5 medium, 4 hard)
    {"word": "CEO", "subcategory": "Corporate", "difficulty": "easy",
     "description": "The chief executive officer responsible for overall company strategy and operations.",
     "tags": ["executive", "strategy", "operations"]},
    {"word": "CFO", "subcategory": "Corporate", "difficulty": "easy",
     "description": "The chief financial officer managing company finances and financial planning.",
     "tags": ["financial", "planning", "finances"]},
    {"word": "Shareholder", "subcategory": "Corporate", "difficulty": "easy",
     "description": "An individual or institution owning shares in a corporation.",
     "tags": ["owner", "shares", "corporation"]},
    {"word": "Corporation", "subcategory": "Corporate", "difficulty": "easy",
     "description": "A legal entity separate from its owners with limited liability protection.",
     "tags": ["legal-entity", "limited-liability", "separate"]},
    {"word": "Board of Directors", "subcategory": "Corporate", "difficulty": "medium",
     "description": "A group elected by shareholders to oversee company management and strategy.",
     "tags": ["elected", "shareholders", "oversight"]},
    {"word": "Stakeholder", "subcategory": "Corporate", "difficulty": "medium",
     "description": "Any party affected by or able to influence a company's actions.",
     "tags": ["affected", "influence", "party"]},
    {"word": "Merger", "subcategory": "Corporate", "difficulty": "medium",
     "description": "The combination of two companies into a single new entity.",
     "tags": ["combination", "new-entity", "two-companies"]},
    {"word": "Acquisition", "subcategory": "Corporate", "difficulty": "medium",
     "description": "One company purchasing most or all of another company's shares.",
     "tags": ["purchasing", "shares", "control"]},
    {"word": "Subsidiary", "subcategory": "Corporate", "difficulty": "medium",
     "description": "A company controlled by a parent company owning majority shares.",
     "tags": ["controlled", "parent", "majority"]},
    {"word": "Joint Venture", "subcategory": "Corporate", "difficulty": "hard",
     "description": "A business arrangement where parties pool resources for a specific project.",
     "tags": ["arrangement", "pool", "project"]},
    {"word": "Restructuring", "subcategory": "Corporate", "difficulty": "hard",
     "description": "Significant reorganization of company operations, debt, or structure.",
     "tags": ["reorganization", "operations", "debt"]},
    {"word": "Spin-off", "subcategory": "Corporate", "difficulty": "hard",
     "description": "Creating an independent company by distributing shares of a subsidiary.",
     "tags": ["independent", "subsidiary", "distributing"]},
    {"word": "Fiduciary Duty", "subcategory": "Corporate", "difficulty": "hard",
     "description": "The legal obligation to act in the best interest of another party.",
     "tags": ["legal", "obligation", "best-interest"]},

    # ACCOUNTING (13 words: 5 easy, 4 medium, 4 hard)
    {"word": "Revenue", "subcategory": "Accounting", "difficulty": "easy",
     "description": "Total income generated from normal business operations before expenses.",
     "tags": ["income", "operations", "total"]},
    {"word": "Profit", "subcategory": "Accounting", "difficulty": "easy",
     "description": "Financial gain when revenue exceeds expenses and costs.",
     "tags": ["gain", "revenue", "exceeds"]},
    {"word": "Loss", "subcategory": "Accounting", "difficulty": "easy",
     "description": "Financial deficit when expenses exceed revenue over a period.",
     "tags": ["deficit", "expenses", "exceed"]},
    {"word": "Asset", "subcategory": "Accounting", "difficulty": "easy",
     "description": "A resource with economic value owned or controlled by an entity.",
     "tags": ["resource", "value", "owned"]},
    {"word": "Liability", "subcategory": "Accounting", "difficulty": "easy",
     "description": "A financial obligation or debt owed to another party.",
     "tags": ["obligation", "debt", "owed"]},
    {"word": "Equity", "subcategory": "Accounting", "difficulty": "medium",
     "description": "The residual interest in assets after deducting liabilities.",
     "tags": ["residual", "assets", "liabilities"]},
    {"word": "Balance Sheet", "subcategory": "Accounting", "difficulty": "medium",
     "description": "A snapshot of assets, liabilities, and equity at a specific date.",
     "tags": ["snapshot", "assets", "liabilities"]},
    {"word": "Income Statement", "subcategory": "Accounting", "difficulty": "medium",
     "description": "A report showing revenues, expenses, and profit over a period.",
     "tags": ["report", "revenues", "period"]},
    {"word": "Cash Flow", "subcategory": "Accounting", "difficulty": "medium",
     "description": "The net amount of cash moving in and out of a business.",
     "tags": ["net", "moving", "business"]},
    {"word": "Depreciation", "subcategory": "Accounting", "difficulty": "medium",
     "description": "Allocating the cost of a tangible asset over its useful life.",
     "tags": ["allocating", "tangible", "useful-life"]},
    {"word": "EBITDA", "subcategory": "Accounting", "difficulty": "hard",
     "description": "Earnings before interest and taxes plus depreciation amortization.",
     "tags": ["earnings", "operating", "profit"]},
    {"word": "GAAP", "subcategory": "Accounting", "difficulty": "hard",
     "description": "Generally accepted accounting principles governing financial reporting standards.",
     "tags": ["principles", "standards", "reporting"]},
    {"word": "Audit", "subcategory": "Accounting", "difficulty": "hard",
     "description": "An independent examination of financial statements for accuracy and compliance.",
     "tags": ["examination", "independent", "compliance"]},

    # ECONOMICS (11 words: 4 easy, 4 medium, 3 hard)
    {"word": "Inflation", "subcategory": "Economics", "difficulty": "easy",
     "description": "A general increase in prices and decrease in purchasing power over time.",
     "tags": ["prices", "purchasing-power", "increase"]},
    {"word": "Recession", "subcategory": "Economics", "difficulty": "easy",
     "description": "A significant decline in economic activity lasting more than a few months.",
     "tags": ["decline", "activity", "months"]},
    {"word": "GDP", "subcategory": "Economics", "difficulty": "easy",
     "description": "Gross domestic product measuring the total value of goods and services produced.",
     "tags": ["total-value", "goods", "services"]},
    {"word": "Currency", "subcategory": "Economics", "difficulty": "easy",
     "description": "A system of money in general use within a particular country.",
     "tags": ["money", "system", "country"]},
    {"word": "Deflation", "subcategory": "Economics", "difficulty": "medium",
     "description": "A general decrease in prices often signaling economic contraction.",
     "tags": ["decrease", "prices", "contraction"]},
    {"word": "Unemployment Rate", "subcategory": "Economics", "difficulty": "medium",
     "description": "The percentage of the labor force that is jobless and seeking work.",
     "tags": ["percentage", "labor-force", "jobless"]},
    {"word": "Fiscal Policy", "subcategory": "Economics", "difficulty": "medium",
     "description": "Government spending and taxation decisions influencing the economy.",
     "tags": ["government", "spending", "taxation"]},
    {"word": "Monetary Policy", "subcategory": "Economics", "difficulty": "medium",
     "description": "Central bank actions controlling money supply and interest rates.",
     "tags": ["central-bank", "money-supply", "control"]},
    {"word": "Depression", "subcategory": "Economics", "difficulty": "hard",
     "description": "A severe and prolonged recession with very high unemployment.",
     "tags": ["severe", "prolonged", "unemployment"]},
    {"word": "Opportunity Cost", "subcategory": "Economics", "difficulty": "hard",
     "description": "The value of the next best alternative forgone when making a choice.",
     "tags": ["value", "alternative", "forgone"]},
    {"word": "Trade Deficit", "subcategory": "Economics", "difficulty": "hard",
     "description": "When a country imports more goods and services than it exports.",
     "tags": ["imports", "exports", "country"]},

    # CRYPTO (10 words: 3 easy, 4 medium, 3 hard)
    {"word": "Bitcoin", "subcategory": "Crypto", "difficulty": "easy",
     "description": "The first decentralized digital currency using blockchain technology.",
     "tags": ["decentralized", "digital", "blockchain"]},
    {"word": "Ethereum", "subcategory": "Crypto", "difficulty": "easy",
     "description": "A programmable blockchain platform enabling smart contracts and dApps.",
     "tags": ["programmable", "smart-contracts", "platform"]},
    {"word": "Cryptocurrency", "subcategory": "Crypto", "difficulty": "easy",
     "description": "Digital assets using cryptography for secure financial transactions.",
     "tags": ["digital", "cryptography", "secure"]},
    {"word": "Blockchain", "subcategory": "Crypto", "difficulty": "medium",
     "description": "A distributed ledger recording transactions across a network of computers.",
     "tags": ["distributed", "ledger", "network"]},
    {"word": "Wallet", "subcategory": "Crypto", "difficulty": "medium",
     "description": "Software or hardware storing private keys for accessing crypto assets.",
     "tags": ["private-keys", "storing", "access"]},
    {"word": "Exchange", "subcategory": "Crypto", "difficulty": "medium",
     "description": "A platform for buying, selling, and trading cryptocurrencies.",
     "tags": ["platform", "trading", "buying-selling"]},
    {"word": "NFT", "subcategory": "Crypto", "difficulty": "medium",
     "description": "Non-fungible token representing unique ownership of a digital asset.",
     "tags": ["non-fungible", "unique", "ownership"]},
    {"word": "Mining", "subcategory": "Crypto", "difficulty": "hard",
     "description": "Validating transactions and adding blocks to a proof-of-work blockchain.",
     "tags": ["validating", "proof-of-work", "blocks"]},
    {"word": "Smart Contract", "subcategory": "Crypto", "difficulty": "hard",
     "description": "Self-executing code on a blockchain that runs when conditions are met.",
     "tags": ["self-executing", "code", "conditions"]},
    {"word": "DeFi", "subcategory": "Crypto", "difficulty": "hard",
     "description": "Decentralized finance applications recreating traditional financial services on blockchain.",
     "tags": ["decentralized", "finance", "traditional"]},

    # REAL ESTATE (12 words: 4 easy, 4 medium, 4 hard)
    {"word": "Real Estate", "subcategory": "Real Estate", "difficulty": "easy",
     "description": "Property consisting of land and the buildings on it.",
     "tags": ["property", "land", "buildings"]},
    {"word": "Down Payment", "subcategory": "Real Estate", "difficulty": "easy",
     "description": "The initial upfront cash payment made when purchasing a property.",
     "tags": ["upfront", "cash", "purchasing"]},
    {"word": "Lease", "subcategory": "Real Estate", "difficulty": "easy",
     "description": "A contract granting temporary use of property in exchange for rent.",
     "tags": ["contract", "temporary", "rent"]},
    {"word": "Appraisal", "subcategory": "Real Estate", "difficulty": "easy",
     "description": "A professional estimate of a property's fair market value.",
     "tags": ["estimate", "fair-value", "professional"]},
    {"word": "Closing Costs", "subcategory": "Real Estate", "difficulty": "medium",
     "description": "Fees and expenses paid at the finalization of a real estate transaction.",
     "tags": ["fees", "finalization", "transaction"]},
    {"word": "Property Tax", "subcategory": "Real Estate", "difficulty": "medium",
     "description": "An annual tax on real estate assessed by local government.",
     "tags": ["annual", "assessed", "local-government"]},
    {"word": "Escrow", "subcategory": "Real Estate", "difficulty": "medium",
     "description": "A neutral third party holding funds and documents until conditions are met.",
     "tags": ["neutral", "holding", "conditions"]},
    {"word": "Zoning", "subcategory": "Real Estate", "difficulty": "medium",
     "description": "Government regulations controlling land use and building types in specific areas.",
     "tags": ["regulations", "land-use", "building-types"]},
    {"word": "Cap Rate", "subcategory": "Real Estate", "difficulty": "hard",
     "description": "Capitalization rate measuring expected return on an investment property.",
     "tags": ["capitalization", "return", "investment"]},
    {"word": "Foreclosure", "subcategory": "Real Estate", "difficulty": "hard",
     "description": "Legal process where a lender seizes property after borrower defaults.",
     "tags": ["legal-process", "lender", "defaults"]},
    {"word": "Home Equity", "subcategory": "Real Estate", "difficulty": "hard",
     "description": "The difference between property value and outstanding mortgage balance.",
     "tags": ["difference", "value", "mortgage"]},
    {"word": "Home Loan", "subcategory": "Real Estate", "difficulty": "hard",
     "description": "A loan secured by real property used to purchase a residence.",
     "tags": ["loan", "secured", "property"]},
]


# =============================================================================
# HINT TEMPLATES PER SUBCATEGORY - Using ONLY these stems (disjoint from imposters):
# INVESTING: buy, trade, track, watch, retirement, ticker, diversify, analyze, growth, rebalance, compare, compound, beta, alpha, sharpe, correlation, deviation, efficient
# BANKING: visit, branch, mobile, statement, balance, compare, fee, teller, direct, deposit, atm, access, negotiate, term, lender, shop, offer, payment, history, rating, budget, automatic, review, agreement, duration, yield, curve, spread, sovereign, benchmark, convexity, forward, implied, basis, point, value, calculation
# STARTUP: founder, silicon, valley, investor, slide, vocabulary, rapid, negotiate, board, approval, ownership, percentage, model, spreadsheet, round, dilution, waterfall, distribution, anti-dilution, protection, participation, rights, liquidation, preference, vesting, schedule, qualified, small, business, stock, rules
# CORPORATE: company, decision, annual, report, executive, responsible, share, price, react, owner, vote, business, headline, strategic, rationale, organizational, chart, synergies, regulatory, review, integration, risk, due, diligence, accretion, dilution, analysis, poison, pill, defense, golden, parachute, proxy, fight, staggered, structure, revlon, duties
# ACCOUNTING: track, number, month, financial, statement, professional, calculate, figure, business, money, record, transaction, balance, book, standard, principle, adjust, entry, year-end, tax, filing, auditor, accuracy, reconcile, account, accrual, cash, basis, fair, value, measurement, hierarchy, deferred, realization, revenue, recognition, criteria, lease, standard, impairment, testing, variable, consideration, constraint
# ECONOMICS: news, discuss, daily, wallet, government, monitor, cyclically, expert, debate, cause, shopping, signal, economy, health, policy, response, data, leading, indicator, trouble, central, bank, target, exchange, rate, abroad, forecast, quarter, phillips, curve, trade-off, nairu, estimate, rational, expectations, theory, dsge, model, parameter, calibration, hysteresis, effect, persist, countercyclical
# CRYPTO: trading, platform, price, swing, wild, store, secure, app, distributed, ledger, validate, block, reward, digital, money, programmable, agreement, transaction, fee, consensus, mechanism, chain, financial, token, design, second, layer, scale, throughput, mev, extraction, validator, zero-knowledge, proof, verification, byzantine, fault, tolerance, improvement, proposal, code, rollup, architecture, slashing, condition, punish, bad, act
# REAL ESTATE: house, agent, concept, closing, process, monthly, payment, standard, transaction, component, affordability, calculation, negotiate, seller, determine, investment, return, inspect, issue, written, agreement, deduction, available, compression, trend, like-kind, exchange, rules, recapture, depreciation, cost, segregation, study, benefit, waterfall, distribution, model, promote, structure, align, incentive
# =============================================================================

HINT_TEMPLATES = {
    "Investing": {
        "easy": [
            lambda w: "Buy a piece of a corporation",
            lambda w: "Trade on a major exchange",
            lambda w: "Track performance over many years",
            lambda w: "Watch prices change daily",
            lambda w: "Retirement accounts often hold these",
            lambda w: "Ticker symbols identify each one",
        ],
        "medium": [
            lambda w: "Diversify across multiple sectors",
            lambda w: "Analyze fundamentals before purchase",
            lambda w: "Long-term growth beats savings",
            lambda w: "Rebalance the mix periodically",
            lambda w: "Compare returns to a benchmark",
            lambda w: "Compound growth works over decades",
        ],
        "hard": [
            lambda w: "Beta measures systematic risk exposure",
            lambda w: "Alpha represents excess return",
            lambda w: "Sharpe ratio adjusts for volatility",
            lambda w: "Correlation to the broader index",
            lambda w: "Standard deviation of monthly returns",
            lambda w: "Efficient frontier optimization model",
        ],
    },
    "Banking": {
        "easy": [
            lambda w: "Visit a branch or use mobile app",
            lambda w: "Monthly statement shows the balance",
            lambda w: "Compare fees across institutions",
            lambda w: "Ask the teller for help",
            lambda w: "Direct deposit goes here first",
            lambda w: "ATM access for cash needs",
        ],
        "medium": [
            lambda w: "Negotiate better terms with lender",
            lambda w: "Shop around for the best offer",
            lambda w: "Payment history affects your rating",
            lambda w: "Monthly budget includes this cost",
            lambda w: "Set up automatic payments",
            lambda w: "Review the agreement carefully",
        ],
        "hard": [
            lambda w: "Duration risk affects bond price",
            lambda w: "Yield curve shows term structure",
            lambda w: "Spread over sovereign benchmarks",
            lambda w: "Convexity adjustment may be needed",
            lambda w: "Forward rates implied by the curve",
            lambda w: "Basis point value calculation",
        ],
    },
    "Startup": {
        "easy": [
            lambda w: "Founders need this to grow",
            lambda w: "Silicon Valley uses this term",
            lambda w: "Investors ask about it often",
            lambda w: "Slide appears in every deck",
            lambda w: "Common vocabulary for founders",
            lambda w: "Equals rapid growth potential",
        ],
        "medium": [
            lambda w: "Negotiated during the agreement",
            lambda w: "Board approval required for this",
            lambda w: "Affects founder ownership percentage",
            lambda w: "Model it in the spreadsheet",
            lambda w: "Happens before the next round",
            lambda w: "Dilution calculations matter here",
        ],
        "hard": [
            lambda w: "Waterfall distribution method",
            lambda w: "Anti-dilution protection clause",
            lambda w: "Participation rights provision",
            lambda w: "Liquidation preference stack order",
            lambda w: "Vesting schedule design choice",
            lambda w: "Qualified small business stock rules",
        ],
    },
    "Corporate": {
        "easy": [
            lambda w: "Big company makes this decision",
            lambda w: "Appears in the annual report",
            lambda w: "Top executive is responsible",
            lambda w: "Share price often reacts",
            lambda w: "Owners vote on major moves",
            lambda w: "Business headlines cover it",
        ],
        "medium": [
            lambda w: "Strategic rationale must be clear",
            lambda w: "Changes the organizational chart",
            lambda w: "Synergies are expected benefits",
            lambda w: "Regulatory review may be needed",
            lambda w: "Integration risk is significant",
            lambda w: "Due diligence takes months",
        ],
        "hard": [
            lambda w: "Accretion dilution analysis model",
            lambda w: "Poison pill defense mechanism",
            lambda w: "Golden parachute clause detail",
            lambda w: "Proxy fight scenario planning",
            lambda w: "Staggered board structure impact",
            lambda w: "Revlon duties may be triggered",
        ],
    },
    "Accounting": {
        "easy": [
            lambda w: "Track this number every month",
            lambda w: "Found on financial statements",
            lambda w: "Professional calculates the figure",
            lambda w: "Shows if business makes money",
            lambda w: "Record every transaction carefully",
            lambda w: "Balance the books regularly",
        ],
        "medium": [
            lambda w: "Follows standard principles strictly",
            lambda w: "Adjust entries at year-end",
            lambda w: "Impacts the tax filing",
            lambda w: "Checker verifies for accuracy",
            lambda w: "Reconcile accounts quarterly",
            lambda w: "Accrual versus cash basis method",
        ],
        "hard": [
            lambda w: "Fair value measurement hierarchy",
            lambda w: "Deferred tax item realization",
            lambda w: "Income recognition criteria steps",
            lambda w: "Lease standard update applies",
            lambda w: "Impairment testing requirement",
            lambda w: "Variable consideration constraint",
        ],
    },
    "Economics": {
        "easy": [
            lambda w: "News discusses this daily",
            lambda w: "Affects everyone's wallet",
            lambda w: "Government monitors the numbers",
            lambda w: "Goes up and down cyclically",
            lambda w: "Experts debate the causes",
            lambda w: "Feel it when shopping",
        ],
        "medium": [
            lambda w: "Signals the economy health",
            lambda w: "Policy response follows the data",
            lambda w: "Leading indicator of trouble",
            lambda w: "Central bank targets the level",
            lambda w: "Affects exchange rates abroad",
            lambda w: "Forecasted each quarter",
        ],
        "hard": [
            lambda w: "Phillips curve trade-off relationship",
            lambda w: "NAIRU estimate is debated",
            lambda w: "Rational expectations theory applies",
            lambda w: "DSGE model parameter calibration",
            lambda w: "Hysteresis effect can persist",
            lambda w: "Countercyclical policy may help",
        ],
    },
    "Crypto": {
        "easy": [
            lambda w: "Buy on a trading platform",
            lambda w: "Price swings can be wild",
            lambda w: "Store in a secure app",
            lambda w: "Built on distributed ledger",
            lambda w: "Validate units for rewards",
            lambda w: "Digital money alternative",
        ],
        "medium": [
            lambda w: "Programmable agreement platform",
            lambda w: "Transaction fees apply here",
            lambda w: "Consensus mechanism secures it",
            lambda w: "Financial app built on chain",
            lambda w: "Token design is critical",
            lambda w: "Second layer scales throughput",
        ],
        "hard": [
            lambda w: "MEV extraction by validators",
            lambda w: "Zero-knowledge proof verification",
            lambda w: "Byzantine fault tolerance model",
            lambda w: "Improvement proposal changes code",
            lambda w: "Rollup architecture scales execution",
            lambda w: "Slashing conditions punish bad acts",
        ],
    },
    "Real Estate": {
        "easy": [
            lambda w: "Buy a house involves this",
            lambda w: "Agent explains the concept",
            lambda w: "Part of closing process",
            lambda w: "Monthly payment includes it",
            lambda w: "Property comes with this",
            lambda w: "Standard transaction component",
        ],
        "medium": [
            lambda w: "Affects affordability calculation",
            lambda w: "Negotiate with the seller",
            lambda w: "Determines investment return",
            lambda w: "Inspect for any issues",
            lambda w: "Written in the agreement",
            lambda w: "Deduction may be available",
        ],
        "hard": [
            lambda w: "Compression trend in the market",
            lambda w: "Like-kind exchange rules apply",
            lambda w: "Recapture tax on depreciation",
            lambda w: "Cost segregation study benefit",
            lambda w: "Waterfall distribution model used",
            lambda w: "Promote structure aligns incentives",
        ],
    },
}

# Default templates for any subcategory not explicitly covered
DEFAULT_HINTS = {
    "easy": [
        lambda w: "Learn the basic concept",
        lambda w: "Important term to know",
        lambda w: "Common vocabulary word",
        lambda w: "Fundamental idea here",
        lambda w: "Used in daily work",
        lambda w: "Widely recognized term",
    ],
    "medium": [
        lambda w: "Deeper knowledge required",
        lambda w: "Affects key decisions made",
        lambda w: "Professionals use this daily",
        lambda w: "Calculate the figure correctly",
        lambda w: "Applied in real practice",
        lambda w: "Advanced concept here",
    ],
    "hard": [
        lambda w: "Technical analysis is needed",
        lambda w: "Expert level knowledge required",
        lambda w: "Quantitative modeling applies",
        lambda w: "Nuanced detail matters",
        lambda w: "Specialized expertise helps",
        lambda w: "Edge case handling skill",
    ],
}


# =============================================================================
# IMPOSTER TEMPLATES PER SUBCATEGORY - Using ONLY these stems (COMPLETELY DISJOINT from hints):
# INVESTING: oak, tree, river, stone, mountain, peak, valley, forest, meadow, stream, bird, nest, feather, wing, flight
# BANKING: whisk, bowl, oven, mitt, spice, rack, pan, pot, spoon, fork, knife, plate, cup, mug, saucer
# STARTUP: rocket, ship, space, station, satellite, dish, orbit, planet, moon, star, galaxy, comet, meteor, asteroid, astronaut
# CORPORATE: piano, key, violin, bow, drum, set, guitar, string, flute, reed, trumpet, valve, trombone, slide, baton
# ACCOUNTING: tennis, court, golf, club, swim, lane, bike, helmet, ski, slope, skate, rink, ball, glove, racket
# ECONOMICS: sunny, sky, rain, cloud, wind, gust, storm, front, pressure, dew, frost, mist, haze, smog, barometer
# CRYPTO: rose, bush, garden, hose, lawn, mower, rake, shovel, spade, fork, hoe, trowel, pruner, shear, sprinkler
# REAL ESTATE: paper, clip, stapler, tool, desk, lamp, file, folder, binder, tack, pin, tape, glue, scissors
# =============================================================================

IMPOSTER_TEMPLATES = {
    "Investing": {
        "easy": [
            lambda w: "Oak tree",
            lambda w: "River stone",
            lambda w: "Mountain peak",
        ],
        "medium": [
            lambda w: "Forest meadow",
            lambda w: "Valley stream",
            lambda w: "Bird nest",
        ],
        "hard": [
            lambda w: "Feather wing",
            lambda w: "Flight path",
            lambda w: "Eagle soar",
        ],
    },
    "Banking": {
        "easy": [
            lambda w: "Whisk bowl",
            lambda w: "Oven mitt",
            lambda w: "Spice rack",
        ],
        "medium": [
            lambda w: "Frying pan",
            lambda w: "Cooking pot",
            lambda w: "Wooden spoon",
        ],
        "hard": [
            lambda w: "Silver fork",
            lambda w: "Sharp knife",
            lambda w: "Dinner plate",
        ],
    },
    "Startup": {
        "easy": [
            lambda w: "Rocket ship",
            lambda w: "Space station",
            lambda w: "Satellite dish",
        ],
        "medium": [
            lambda w: "Orbit path",
            lambda w: "Planet moon",
            lambda w: "Star galaxy",
        ],
        "hard": [
            lambda w: "Comet meteor",
            lambda w: "Asteroid belt",
            lambda w: "Astronaut suit",
        ],
    },
    "Corporate": {
        "easy": [
            lambda w: "Piano key",
            lambda w: "Violin bow",
            lambda w: "Drum set",
        ],
        "medium": [
            lambda w: "Guitar string",
            lambda w: "Flute reed",
            lambda w: "Trumpet valve",
        ],
        "hard": [
            lambda w: "Trombone slide",
            lambda w: "Baton wave",
            lambda w: "Cello bridge",
        ],
    },
    "Accounting": {
        "easy": [
            lambda w: "Tennis court",
            lambda w: "Golf club",
            lambda w: "Swim lane",
        ],
        "medium": [
            lambda w: "Bike helmet",
            lambda w: "Ski slope",
            lambda w: "Skate rink",
        ],
        "hard": [
            lambda w: "Soccer ball",
            lambda w: "Baseball glove",
            lambda w: "Tennis racket",
        ],
    },
    "Economics": {
        "easy": [
            lambda w: "Sunny sky",
            lambda w: "Rain cloud",
            lambda w: "Wind gust",
        ],
        "medium": [
            lambda w: "Storm front",
            lambda w: "Pressure zone",
            lambda w: "Morning dew",
        ],
        "hard": [
            lambda w: "Frost pattern",
            lambda w: "Mist haze",
            lambda w: "Barometer reading",
        ],
    },
    "Crypto": {
        "easy": [
            lambda w: "Rose bush",
            lambda w: "Garden hose",
            lambda w: "Lawn mower",
        ],
        "medium": [
            lambda w: "Garden rake",
            lambda w: "Digging spade",
            lambda w: "Hand trowel",
        ],
        "hard": [
            lambda w: "Pruning shear",
            lambda w: "Water sprinkler",
            lambda w: "Garden fork",
        ],
    },
    "Real Estate": {
        "easy": [
            lambda w: "Paper clip",
            lambda w: "Stapler tool",
            lambda w: "Desk lamp",
        ],
        "medium": [
            lambda w: "File folder",
            lambda w: "Ring binder",
            lambda w: "Thumb tack",
        ],
        "hard": [
            lambda w: "Scotch tape",
            lambda w: "Glue stick",
            lambda w: "Office scissors",
        ],
    },
}


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def get_hints(word: str, subcategory: str) -> list[Hint]:
    """Generate 6 hints per difficulty level for a word."""
    templates = HINT_TEMPLATES.get(subcategory, DEFAULT_HINTS)
    hints = []

    for level, label in [(3, "easy"), (2, "medium"), (1, "hard")]:
        level_templates = templates.get(label, DEFAULT_HINTS[label])
        for i, template in enumerate(level_templates):
            if i >= 6:
                break
            hint_text = template(word)
            hints.append(Hint(text=hint_text, level=level))

    return hints


def get_imposters(word: str, subcategory: str) -> list[ImposterWord]:
    """Generate 3 imposters per difficulty level for a word."""
    templates = IMPOSTER_TEMPLATES.get(subcategory, IMPOSTER_TEMPLATES["Investing"])
    imposters = []

    for level, label in [(1, "easy"), (2, "medium"), (3, "hard")]:
        level_templates = templates.get(label, IMPOSTER_TEMPLATES["Investing"][label])
        for i, template in enumerate(level_templates):
            if i >= 3:
                break
            imposter_text = template(word)
            imposters.append(ImposterWord(text=imposter_text, level=level))

    return imposters


def create_business_finance_pack() -> WordPack:
    """Create the business_finance word pack with ~100 words."""
    words: list[WordRecord] = []

    for entry in BUSINESS_FINANCE_WORDS:
        word = entry["word"]
        subcategory = entry["subcategory"]
        difficulty = WordDifficulty(entry["difficulty"])
        description = entry["description"]
        tags = entry["tags"]

        # Generate hints and imposters
        hints = get_hints(word, subcategory)
        imposters = get_imposters(word, subcategory)

        # Create word record
        word_id = f"wf:business_finance:{word.lower().replace(' ', '-').replace('/', '-')}"
        record = WordRecord(
            id=word_id,
            word=word,
            category="business_finance",
            subcategory=subcategory,
            difficulty=difficulty,
            tags=tags,
            is_adult=False,
            hints=hints,
            imposters=imposters,
            description=description,
            source="wordforge",
        )
        words.append(record)

    # Count difficulties for meta
    diff_counts = {"easy": 0, "medium": 0, "hard": 0}
    for w in words:
        diff_counts[w.difficulty.value] += 1

    # Count subcategories
    subcat_counts = {}
    for w in words:
        subcat_counts[w.subcategory] = subcat_counts.get(w.subcategory, 0) + 1

    print(f"Subcategory distribution: {subcat_counts}")
    print(f"Difficulty distribution: {diff_counts}")
    print(f"Total words: {len(words)}")

    # Build pack metadata
    meta = PackMeta(
        id="business_finance",
        name="Business & Finance",
        description="Money, work life, markets and the economy.",
        icon="payments",
        is_adult=False,
        count=len(words),
        difficulty=diff_counts,
        schema_version=3,
        content_version="1.0.0",
        generated_at=datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        source="wordforge",
    )

    return WordPack(meta=meta, words=words)


# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

def main():
    """Main entry point - generate and export the pack."""
    print("Generating Business & Finance word pack...")

    pack = create_business_finance_pack()

    # Export to offline_packs directory
    output_dir = Path(__file__).parent.parent / "output" / "offline_packs"
    output_dir.mkdir(parents=True, exist_ok=True)

    output_path = output_dir / "business_finance.json"

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(pack.as_json(), f, indent=2, ensure_ascii=False)

    print(f"\nPack saved to: {output_path}")
    print(f"Total words: {pack.meta.count}")
    print(f"Difficulty distribution: {pack.meta.difficulty}")

    # Print sample word
    sample = pack.words[0]
    print(f"\nSample word: {sample.word}")
    print(f"  Subcategory: {sample.subcategory}")
    print(f"  Difficulty: {sample.difficulty.value}")
    print(f"  Description: {sample.description}")
    print(f"  Tags: {sample.tags}")
    print(f"  Hints (easy): {sample.hints_by_level().get(3, [])[:3]}")
    print(f"  Imposters (easy): {sample.imposters_by_level().get(1, [])[:3]}")

    print("\nDone!")


if __name__ == "__main__":
    main()