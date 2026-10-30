const mongoose = require('mongoose');

const loanApplicationSchema = new mongoose.Schema(
  {
    applicationId: {
      type: String,
      required: true,
      unique: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false,
    },
    userPhone: {
      type: String,
      required: true,
    },
    userName: {
      type: String,
      default: '',
    },
    purpose: {
      type: String,
      required: true,
      default: 'Personal Expense',
    },
    principalAmount: {
      type: Number,
      required: true,
      min: 5000,
      max: 200000,
    },
    tenureDays: {
      type: Number,
      required: true,
      min: 15,
      max: 90,
    },
    dailyInterestRate: {
      type: Number,
      default: 0.01, // 1% per day
    },
    processingFeePercent: {
      type: Number,
      default: 10, // 10%
    },
    processingFee: {
      type: Number,
      required: true,
    },
    totalInterest: {
      type: Number,
      required: true,
    },
    totalPayable: {
      type: Number,
      required: true,
    },
    status: {
      type: String,
      enum: ['Submitted', 'Under Review', 'Approved', 'Rejected', 'Disbursed', 'Repaid'],
      default: 'Submitted',
    },
    currentStep: {
      type: Number,
      default: 2, // 1: Submitted, 2: Under Review, 3: E-KYC, 4: E-Nach, 5: E-Sign, 6: Disbursement
    },
    statusMessage: {
      type: String,
      default: "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.",
    },
    offerAmount: {
      type: Number,
      default: 10000,
    },
    offerTenureDays: {
      type: Number,
      default: 90,
    },
    offerPayable: {
      type: Number,
      default: 10600,
    },
    isOfferAccepted: {
      type: Boolean,
      default: false,
    },
    repaidAmount: {
      type: Number,
      default: 0,
    },
    paymentStatus: {
      type: String,
      enum: ['Pending', 'Completed'],
      default: 'Pending',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('LoanApplication', loanApplicationSchema);
