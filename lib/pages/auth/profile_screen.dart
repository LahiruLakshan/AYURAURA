import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/profile_widgets/profile_widget.dart';
import '../../../widgets/profile_widgets/accout_settings_widget.dart';
import '../../../widgets/profile_widgets/contact_info_widget.dart';
import '../../../widgets/profile_widgets/subscription_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool notificationsEnabled = true;
  bool locationEnabled = true;
  bool analyticsEnabled = true;
  double logoutScale = 1.0;
  bool _isLoading = true;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<Map<String, dynamic>> _getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  Future<void> loadUserData() async {
    if (user != null) {
      try {
        final data = await _getUserData(user!.uid);
        setState(() {
          userData = data;
          _isLoading = false;
        });
      } catch (e) {
        print("Error loading user data: $e");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // mainProvider.clearUserData(); // Uncomment if you have a provider
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/lucide_bell.svg',
              height: 22,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileCard(
              userName: userData['name'] ?? 'User',
            ),
            const SizedBox(height: 24),
            ContactInfoCard(
              email: userData['email'] ?? user?.email ?? 'No email',
              age: userData['age'].toString() ?? 'No age',
              address: 'piliyandala',
            ),
            const SizedBox(height: 24),
            AccountSettingsCard(),
            const SizedBox(height: 24),
            SubscriptionPlanCard(
              currentPlan: "Premium Plan",
              description: 'Access to all premium features including unlimited plant scans and detailed treatment plans.',
              renewalDate: 'June 15, 2025',
              plan: "Annual (\$59.99/year)",
              active: true,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            // Logout Button
            GestureDetector(
              onTapDown: (_) => setState(() => logoutScale = 0.95),
              onTapUp: (_) => setState(() => logoutScale = 1.0),
              onTapCancel: () => setState(() => logoutScale = 1.0),
              onTap: _logout,
              child: Transform.scale(
                scale: logoutScale,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/logout.svg', // Add your logout icon
                        height: 20,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "AyurAura v1.0.0",
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}