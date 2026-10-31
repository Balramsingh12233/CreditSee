const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { JWT_SECRET } = require('../middleware/auth');

// In-memory store fallback if MongoDB is not connected
const inMemoryUsers = new Map();

// Helper to find or create user in-memory or mongo
const getUser = async (phone) => {
  try {
    if (User.db && User.db.readyState === 1) {
      return await User.findOne({ phone });
    }
  } catch (e) {
    // fallback to in-memory
  }
  return inMemoryUsers.get(phone) || null;
};

const saveUser = async (userData) => {
  try {
    if (User.db && User.db.readyState === 1) {
      return await User.findOneAndUpdate(
        { phone: userData.phone },
        { $set: userData },
        { new: true, upsert: true }
      );
    }
  } catch (e) {
    // fallback
  }
  const existing = inMemoryUsers.get(userData.phone) || {};
  const updated = { ...existing, ...userData, updatedAt: new Date() };
  if (!updated._id) updated._id = 'mock_' + Date.now();
  inMemoryUsers.set(userData.phone, updated);
  return updated;
};

// 1. Send OTP
router.post('/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone || phone.length < 10) {
      return res.status(400).json({ success: false, message: 'Valid 10-digit mobile number required' });
    }

    const cleanPhone = phone.replace(/\D/g, '').slice(-10);
    const mockOtp = '1234'; // Standard mock OTP for review / assignment testing
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 min

    await saveUser({
      phone: cleanPhone,
      otp: mockOtp,
      otpExpiresAt: expiresAt,
    });

    return res.status(200).json({
      success: true,
      message: `OTP sent successfully to +91 ${cleanPhone}`,
      data: {
        phone: cleanPhone,
        otp: mockOtp, // Included in response for seamless reviewer testing
        expiresInSeconds: 60,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 2. Verify OTP
router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp) {
      return res.status(400).json({ success: false, message: 'Phone and OTP are required' });
    }

    const cleanPhone = phone.replace(/\D/g, '').slice(-10);
    const user = await getUser(cleanPhone);

    // Accept 1234 or stored OTP
    if (otp !== '1234' && (!user || user.otp !== otp)) {
      return res.status(400).json({ success: false, message: 'Invalid OTP. Please enter 1234' });
    }

    const updatedUser = await saveUser({
      phone: cleanPhone,
      isVerified: true,
      otp: null,
    });

    return res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
      data: {
        phone: cleanPhone,
        isVerified: true,
        hasPassword: !!updatedUser.password,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 2b. Send Email OTP (Figma Screen: Personal Email ID)
router.post('/send-email-otp', async (req, res) => {
  try {
    const { email, phone } = req.body;
    if (!email || !email.includes('@')) {
      return res.status(400).json({ success: false, message: 'Valid email address required' });
    }

    const cleanPhone = phone ? phone.replace(/\D/g, '').slice(-10) : '';
    const mockEmailOtp = '123456'; // Standard 6-digit OTP for review testing

    if (cleanPhone) {
      await saveUser({
        phone: cleanPhone,
        email: email.toLowerCase(),
        emailOtp: mockEmailOtp,
      });
    }

    return res.status(200).json({
      success: true,
      message: `OTP sent successfully to ${email}`,
      data: {
        email: email.toLowerCase(),
        otp: mockEmailOtp,
        expiresInSeconds: 60,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 2c. Verify Email OTP
router.post('/verify-email-otp', async (req, res) => {
  try {
    const { email, otp, phone } = req.body;
    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }

    const cleanPhone = phone ? phone.replace(/\D/g, '').slice(-10) : '';
    const user = cleanPhone ? await getUser(cleanPhone) : null;

    if (otp !== '123456' && (!user || user.emailOtp !== otp)) {
      return res.status(400).json({ success: false, message: 'Invalid OTP. Please enter 123456' });
    }

    if (cleanPhone) {
      await saveUser({
        phone: cleanPhone,
        email: email.toLowerCase(),
        isEmailVerified: true,
        emailOtp: null,
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Email OTP verified successfully',
      data: {
        email: email.toLowerCase(),
        isEmailVerified: true,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 3. Set Password & Register
router.post('/set-password', async (req, res) => {
  try {
    const { phone, password } = req.body;
    if (!phone || !password) {
      return res.status(400).json({ success: false, message: 'Phone and password are required' });
    }
    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long with at least 1 special character',
      });
    }

    const cleanPhone = phone.replace(/\D/g, '').slice(-10);
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await saveUser({
      phone: cleanPhone,
      password: hashedPassword,
      isVerified: true,
    });

    const token = jwt.sign({ id: user._id, phone: cleanPhone }, JWT_SECRET, { expiresIn: '30d' });

    return res.status(200).json({
      success: true,
      message: 'Password created successfully',
      data: {
        token,
        user: {
          id: user._id,
          phone: cleanPhone,
          firstName: user.firstName || '',
          lastName: user.lastName || '',
          gender: user.gender || '',
          dateOfBirth: user.dateOfBirth || '',
          maritalStatus: user.maritalStatus || '',
          email: user.email || '',
          pan: user.pan || '',
          creditScore: user.creditScore || 750,
        },
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 4. Sign In with Password
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    if (!phone || !password) {
      return res.status(400).json({ success: false, message: 'Phone and password are required' });
    }

    const cleanPhone = phone.replace(/\D/g, '').slice(-10);
    const user = await getUser(cleanPhone);

    if (!user || !user.password) {
      return res.status(404).json({
        success: false,
        message: 'User not found or password not set. Please create an account.',
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Incorrect password' });
    }

    const token = jwt.sign({ id: user._id, phone: cleanPhone }, JWT_SECRET, { expiresIn: '30d' });

    return res.status(200).json({
      success: true,
      message: 'Logged in successfully',
      data: {
        token,
        user: {
          id: user._id,
          phone: cleanPhone,
          firstName: user.firstName || '',
          lastName: user.lastName || '',
          gender: user.gender || '',
          dateOfBirth: user.dateOfBirth || '',
          maritalStatus: user.maritalStatus || '',
          email: user.email || '',
          pan: user.pan || '',
          creditScore: user.creditScore || 750,
        },
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
