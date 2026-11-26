# NeoParlour Partner – Complete Feature Guide & Content Kit

A comprehensive feature breakdown of the **NeoParlour Partner App** (Salon Management & Operations ERP), compiled directly from the production application codebase. Designed specifically for content creators, marketing leads, copywriters, and social media managers.

---

## 🎯 Executive Summary
**NeoParlour Partner** is an all-in-one salon management and booking ecosystem built for salon owners, managers, and beauty stylists across India. It digitizes daily salon workflows—from walk-in customer booking and calendar management to stock tracking, staff commissions, client history, and 100% compliant Indian GST invoicing.

---

## 🏛️ 1. Smart Salon Profile & Digital Storefront
*Empowering salons to stand out digitally and make discovering their physical outlet effortless.*

* **Precision Map Pinning & Auto-Detection:**
  * **Entrance Door Pinning:** Interactive map pin lets owners pinpoint the exact front door / entrance of the salon.
  * **Auto-Detection & Landmark Matching:** GPS auto-detects current location with search support for local roads, areas, and nearby landmarks.
  * Eliminates client navigation confusion and lost appointments.
* **Curated Salon Gallery:**
  * High-res media uploads: Mandatory exterior view (outside ambiance) + at least 2 interior photos (cutting stations, spa rooms) to build client trust.
* **Operating Hours & Business Schedule:**
  * Configurable daily opening and closing hours with conflict validation (prevents setting opening time equal to closing time).
* **Salon QR Code Generator:**
  * Instant QR Code generation and download directly in the app.
  * Ready to print for reception counters and display stands—clients scan to instantly view the salon's menu, packages, and book appointments.
* **Doorstep / Home Services:**
  * One-tap toggle to enable/disable home services with custom travel and visit charges.
* **Paperless KYC Verification:**
  * In-app secure upload for Aadhaar/Govt ID, PAN Card, Shop & Establishment License, and Bank Proof (PDF/Image formats).

---

## 📅 2. Appointment & Calendar Management
*Eliminating double-booking chaos and keeping stylists organized.*

* **Multi-View Real-Time Calendar:**
  * Switch easily between **Today**, **Weekly**, **Monthly**, and **Yearly** overviews.
  * Live status tagging: `Scheduled`, `In-Progress`, `Completed`, `Cancelled`, and `Rescheduled`.
* **Smart Staff Assignment:**
  * Assign or reassign specific stylists/beauticians per booking with immediate status syncing.
* **Transparent Cancellation & Reschedule Tracking:**
  * Controlled cancellation and reschedule workflows with structured reason tracking (distinguishes between owner-initiated and customer-initiated reasons).
* **Client Visit History & CRM:**
  * Comprehensive client records showing total visit counts, lifetime revenue generated, past services taken, assigned staff, and last visit dates.

---

## 💇‍♂️ 3. Dynamic Salon Menu (Services, Combos & Retail)
*Complete control over service pricing, bundling, and visual menu presentation.*

* **Categorized Services:**
  * Preloaded and custom categories (Hair, Skin Care, Spa & Massage, Nail Art, Makeup, Shaving & Grooming, etc.).
  * Gender tagging (Male, Female, Unisex), service duration (in minutes), and transparent pricing.
  * **Drag-and-Drop Reordering:** Salon owners can hold and drag services to customize how they appear on customer devices.
  * **Customer Preview Mode:** Live preview showing exactly how clients will view the salon's service menu.
* **Packages & Combos:**
  * Bundle high-margin services into festive or bridal packages at special combo prices.
  * Set per-customer usage limits and total salon package limits to prevent over-redemption.
* **Retail Product Showcase & Orders:**
  * List and sell retail beauty products (shampoos, serums, face gels) with photo galleries, discounted rates, and stock alerts.
  * Manage customer product orders with full status tracking (Ordered, Completed, Cancelled).

---

## 🎁 4. Offers, Discounts & Promotional Engine
*Turn slow weekdays into fully booked slots.*

* **Flexible Promotional Campaigns:**
  * Create flat ₹ discount or percentage-off (%) offers.
  * Set validity date ranges (`Valid From` to `Valid To`).
* **Campaign Guardrails:**
  * Per-customer redemption limit + total salon campaign limit.
  * Apply offers to specific individual services or broad categories.
* **Offer ROI & Acquisition Analytics:**
  * Detailed metrics tracking total revenue generated exclusively via promotions, number of times claimed, and **new customers acquired** via offers.

---

## 📦 5. Salon Inventory & Back-Bar Consumable Control
*Say goodbye to mysterious stock shortages and product wastage.*

* **Consumables & Retail Inventory:**
  * Track back-bar supplies (shampoos, developers, hair colors, waxes, tools) by custom unit types (ml, grams, pieces, bottles).
* **Staff Stock Allocation:**
  * Issue specific stock quantities to individual stylists with custom notes.
  * Monitor **Allocated vs. Used vs. Remaining** stock per staff member in real time.
* **Automated Reorder Alerts:**
  * Configurable restock thresholds automatically alert the owner before critical items run out.

---

## 👥 6. Staff Management, Attendance & Referrals
*Keep stylists motivated, accountable, and rewarded.*

* **Dual Role-Based Access:**
  * Distinct views, permissions, and navigation flows for **Salon Owner** vs. **Staff / Stylist**.
* **Daily Attendance & Shift Tracker:**
  * Monthly visual calendar tracking Present, Leaves, Half-Days, Paid Leaves, and Total Worked Hours.
* **Digital Leave Approval:**
  * Stylists submit leave requests (Casual, Sick, Paid) directly through the app; owners approve or reject with one tap.
* **Staff Referral Program ("My Referrals"):**
  * Stylists get unique download invitation links for customers.
  * Real-time dashboard tracks: **Invites Sent**, **Downloads**, **Registrations**, and **Reward Points Earned**.

---

## ⚡ 7. Staff "Walk-In" & "On-the-Fly Extend" Tools *(Core USP)*
*Built specifically for high-stress salon rush hours.*

* **Instant Walk-in / Guest Booking:**
  * Stylists can register and book walk-in clients in seconds without forcing them through tedious signup screens.
* **In-Service Appointment Extension:**
  * If a client in the chair asks for an add-on service (e.g. adding a hair spa or beard trim), staff can extend the appointment on-the-fly.
* **Intelligent Schedule Conflict Resolution:**
  * If extending causes an overlap with the stylist's next booking, the app immediately flags the conflict and suggests:
    1. Reassigning the next booking to another available stylist.
    2. Rescheduling the slot with automatic customer communication.

---

## 🧾 8. Digital Invoicing & Indian GST Engine
*Fast, professional billing that clients love and tax consultants approve.*

* **One-Tap Quick Invoicing:**
  * Generate itemized invoices with service charges, discounts, and custom notes.
  * One-tap sharing of digital PDF bills directly to clients via WhatsApp or SMS.
* **Automated Indian GST Compliance:**
  * Built-in 18% GST engine supporting both **Inclusive** and **Exclusive** tax configurations.
  * Legally accurate tax split into **CGST (9%) + SGST (9%)**, or **UTGST (9%)** for Union Territories (Chandigarh, Ladakh, D&D, etc.).
  * Real-time GSTIN format and state-code validation.

---

## 📊 9. Business Intelligence & Revenue Analytics
*No more guessing—know your most profitable services and top performers.*

* **Visual Revenue Growth Graphs:**
  * Interactive charts with filters for Today, Weekly, Monthly, Yearly, and Custom Date Ranges.
  * Net sales, booking volumes, completed vs. cancelled ratios.
* **Staff Performance Leaderboard:**
  * Compare revenue generated per employee and total appointments handled.
* **Customer Loyalty & Birthday Tracker:**
  * Dedicated **Upcoming Customer Birthdays tab** in notifications to send personalized birthday wishes and festive discounts.
* **Review Moderation:**
  * View verified client ratings and approve customer feedback before public display.

---

## 🌐 10. Multilingual & Platform Reliability
*Simple, accessible, and works across languages.*

* **Trilingual Interface:**
  * Native support in **English**, **Hindi (हिंदी)**, and **Marathi (मराठी)**.
  * Switch languages on the fly without logging out.
* **Safe Server Maintenance:**
  * Proactive server maintenance detector ensures salon appointments and financial records are never corrupted or lost during updates.

---

## 📣 Quick Content Strategy Cheatsheet (Hooks & Angles)

| Marketing Angle | Hook / Topic Idea | Featured USP |
| :--- | :--- | :--- |
| **Pain Point: Double Bookings** | *"How Indian salons lose ₹20,000 every month in missed appointments"* | Real-time calendar + intelligent conflict resolver |
| **Pain Point: Stock Pilferage** | *"Where did that ₹1,500 hair spa tub go? Track your back-bar stock"* | Staff-wise inventory allocation & usage tracking |
| **Feature Spotlight: Rush Hours** | *"Client asked for a beard trim mid-haircut? Here’s how to add it without chaos"* | On-the-fly Appointment Extension + Conflict Handler |
| **Feature Spotlight: Walk-ins** | *"Turn every walk-in customer into a repeat digital client in 3 taps"* | Guest Booking & WhatsApp PDF Invoicing |
| **Staff Motivation** | *"Turn your stylists into your best marketing channel"* | Staff Referral Dashboard & Rewards System |
| **Trust & Compliance** | *"Are your salon bills GST compliant? CGST vs UTGST explained"* | Auto 18% CGST/SGST/UTGST Tax Breakdown |
| **Vernacular Reach** | *"Apne salon ka hisaab apni bhasha mein (English, Hindi, Marathi)"* | Trilingual localization |
