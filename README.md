# CreditSea – Loan Application Mobile App & Backend

A full-stack, production-grade Loan Application mobile app developed with **Flutter** (using **GetX** state management & Material 3 design) and a RESTful backend powered by **Node.js, Express, and MongoDB**.

Built strictly following the **CreditSea UI/UX Figma Specifications** and requirements for the **Flutter Developer Assignment**.

---

## 📱 Visual Screen Flow (1:1 Figma Matching)

| Screen # | Screen Name | Key Features & Implementation |
|---|---|---|
| **1 (First)** | **Splash Screen** | Deep navy blue canvas (`#0A4D92`), centered CreditSea logo badge with cyan ship silhouette, smooth scale/fade animations, session check. |
| **2** | **Onboarding / Welcome** | Top carousel (Flexible Loan Options grid), Indian mobile (+91) input, interactive terms checkbox, "Request OTP" CTA, link to Sign In. |
| **3** | **Enter OTP** | Top carousel (Instant Loan Approval), 4-digit auto-advancing OTP boxes, active countdown timer (`00:28`), resend OTP trigger. |
| **4** | **Create Password** | Top carousel (24x7 Customer Care), password & confirm password inputs with eye visibility toggles, dynamic password policy validator. |
| **5 & 8** | **Sign In (Existing Users)** | Top carousel, mobile & password fields, password recovery link, direct sign-in with JWT session generation. |
| **6 & 9** | **Loading / Skeleton State** | High-fidelity shimmer skeleton loading while loading profile & application states. |
| **7 & 10** | **Step 1: Personal Details** | Multi-step indicator `(1) Register` -> `(2) Offer` -> `(3) Approval`. First & Last Name, Gender dropdown, Date of Birth calendar picker, Marital status, PAN & Email. |
| **11** | **Loan Calculator ("Apply for loan")** | 1% Daily Interest & 10% Processing Fee chips, Loan purpose selector, interactive Principal slider (₹ 5,000 - ₹ 2,00,000) & Tenure slider (20 - 90 Days), dynamic live breakdown card. |
| **12** | **Step 2: Our Offerings** | Stepper step 2, 3D golden Rupee coin (`₹`), dynamic personalized congratulations offer card, "Accept Offer" & "Extend Offer" CTAs. |
| **13** | **Step 3: Application Status** | Stepper step 3, unique Loan Application `#CS12323`, 6-stage tracker (*Submitted → Under Review → E-KYC → E-Nach → E-Sign → Disbursement*), active review card, live demo tester controls. |
| **Bonus** | **Dashboard & Credit Health** | Active loan status card with progress bar, Credit Score meter (300-900), mock Razorpay/UPI repayments (boosting score), evaluator demo sheet. |

---

## 🏗️ Architecture & Tech Stack

### Mobile Frontend (Flutter)
- **Framework**: Flutter 3.38+ / Dart 3.10+
- **State Management**: **GetX** (`GetxController`, `Obx`, `Rx`, reactive state separation)
- **Typography & Styling**: Google Fonts (`Outfit`, `Inter`), custom design tokens in `AppColors` and `AppTheme`
- **Network**: `Dio` with custom interceptors, auto token injection, and offline mock fallback
- **Persistent Storage**: `SharedPreferences` (token session, profile cache, active loan ID)
- **Vector Graphics**: `flutter_svg` for crisp logo & coin rendering on all screen densities

### Backend (Node.js & MongoDB)
- **Runtime**: Node.js v18+ / v20+
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose (supports MongoDB Atlas and local MongoDB, with auto-fallback in-memory store so it runs instantly out-of-the-box!)
- **Security & Auth**: JWT (JSON Web Tokens), `bcryptjs` password hashing, CORS, input sanitization

---

## 🚀 Quick Start Guide

### 1. Run the Backend API
```bash
# Navigate to backend directory
cd backend

# Install dependencies (already installed)
npm install

# Start the server (runs on http://localhost:5000)
node server.js
```
> **Health Check**: Visit `http://localhost:5000/api/health` in your browser.

### 2. Run the Flutter App
Open a new terminal at the root project directory:
```bash
# Get Flutter packages
flutter pub get

# Run on Android Emulator or Connected Device
flutter run
```

---

## 📡 Backend API Endpoints

### Authentication (`/api/auth`)
- `POST /api/auth/send-otp` – Sends OTP to mobile number (returns `1234` for review).
- `POST /api/auth/verify-otp` – Validates OTP.
- `POST /api/auth/set-password` – Registers password and generates JWT token.
- `POST /api/auth/login` – Logs in existing user with mobile and password.

### User Profile (`/api/user`)
- `GET /api/user/profile` – Retrieves current user details.
- `PUT /api/user/profile` – Saves personal details (Step 1 Register screen).
- `GET /api/user/credit-score` – Fetches credit score and health insights.

### Loans & Status Tracking (`/api/loans`)
- `POST /api/loans/calculate` – Calculates daily interest (1%), processing fee (10%), and total payable.
- `POST /api/loans/check-eligibility` – Validates basic eligibility and returns customized offer.
- `POST /api/loans/apply` – Submits new loan application (status: `Under Review`, step: `2`).
- `GET /api/loans/:id/status` – Gets live tracking status and step (1 to 6).
- `PATCH /api/loans/:id/status` – **Demo / Evaluator Endpoint**: Instantly changes application status (*Submitted → Under Review → Approved → Disbursed*).
- `POST /api/loans/:id/mock-repayment` – Simulates mock UPI/Razorpay repayment and boosts user credit score (+15 points).

---

## 🛠️ Build APK Deliverable

To generate a standalone APK for device installation:
```bash
# Build release APK
flutter build apk --release

# Output path:
# build/app/outputs/flutter-apk/app-release.apk
```
Or for quick debug APK:
```bash
flutter build apk --debug
```

---

## 🎯 Bonus Features Implemented
1. **Credit Score Meter (300 to 900)**: Visual gauge with financial health category (Excellent/Good/Fair) and tailored credit tips.
2. **Mock Razorpay/UPI Repayments**: Instant mock repayment flow that automatically updates loan status to `Repaid` and increments credit score.
3. **Interactive Evaluator Demo Sheet**: Tap the **"Demo Controls"** floating button anywhere on the tracking screen or dashboard to instantly simulate any step of the 6-stage loan pipeline for live evaluation.
4. **Resilient Dual Storage**: Works seamlessly with live MongoDB Atlas, local MongoDB, or standalone in-memory mode if a reviewer tests without a running database.

---

## 📋 Submission Checklist for Candidate

Fill in your details when submitting your assignment:

```
Name: [Your Full Name]
Phone Number: [Your Phone Number]
Android APK Download Link: [Insert Google Drive Link Here - set to Anyone with link can view]
iPhone Demo Video Link: [Insert YouTube/Drive Link Here]
iPad Demo Video Link: [Insert YouTube/Drive Link Here]
GitHub Repository: [Insert GitHub Link Here]
```
**Send email to**: `hr@creditsea.com`
