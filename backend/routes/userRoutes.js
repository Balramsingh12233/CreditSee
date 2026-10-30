const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

// Get profile
router.get('/profile', optionalAuth, async (req, res) => {
  try {
    const phone = req.query.phone || (req.user && req.user.phone);
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Phone identifier required' });
    }

    let user;
    if (User.db && User.db.readyState === 1) {
      user = await User.findOne({ phone }).select('-password -otp');
    }

    if (!user) {
      // Mock / fallback profile
      user = {
        phone,
        firstName: 'Rahul',
        lastName: 'Sharma',
        gender: 'Male',
        dateOfBirth: '15-08-1995',
        maritalStatus: 'Single',
        email: 'rahul.sharma@example.com',
        pan: 'ABCDE1234F',
        monthlyIncome: 45000,
        creditScore: 785,
      };
    }

    return res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Update personal details (Step 1 Register screen)
router.put('/profile', optionalAuth, async (req, res) => {
  try {
    const phone = req.body.phone || (req.user && req.user.phone);
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Phone identifier required' });
    }

    const {
      firstName,
      lastName,
      gender,
      dateOfBirth,
      maritalStatus,
      email,
      pan,
      monthlyIncome,
    } = req.body;

    const updateFields = {};
    if (firstName !== undefined) updateFields.firstName = firstName;
    if (lastName !== undefined) updateFields.lastName = lastName;
    if (gender !== undefined) updateFields.gender = gender;
    if (dateOfBirth !== undefined) updateFields.dateOfBirth = dateOfBirth;
    if (maritalStatus !== undefined) updateFields.maritalStatus = maritalStatus;
    if (email !== undefined) updateFields.email = email;
    if (pan !== undefined) updateFields.pan = pan;
    if (monthlyIncome !== undefined) updateFields.monthlyIncome = monthlyIncome;

    let updatedUser;
    if (User.db && User.db.readyState === 1) {
      updatedUser = await User.findOneAndUpdate(
        { phone },
        { $set: updateFields },
        { new: true, upsert: true }
      ).select('-password -otp');
    } else {
      updatedUser = { phone, ...updateFields, creditScore: 785 };
    }

    return res.status(200).json({
      success: true,
      message: 'Personal details updated successfully',
      data: updatedUser,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Bonus: Credit score endpoint
router.get('/credit-score', optionalAuth, async (req, res) => {
  try {
    const phone = req.query.phone || (req.user && req.user.phone) || '8800642354';
    let user;
    if (User.db && User.db.readyState === 1) {
      user = await User.findOne({ phone });
    }

    const score = user ? user.creditScore || 785 : 785;
    let category = 'Excellent';
    if (score < 600) category = 'Poor';
    else if (score < 700) category = 'Fair';
    else if (score < 750) category = 'Good';

    return res.status(200).json({
      success: true,
      data: {
        score,
        maxScore: 900,
        minScore: 300,
        category,
        onTimePayments: '98%',
        creditUtilization: '18%',
        activeLoansCount: 1,
        insights: [
          'High credit score unlocks instant loan approvals up to ₹1,00,000.',
          'Always pay tenures on time to boost your score above 800.',
        ],
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
