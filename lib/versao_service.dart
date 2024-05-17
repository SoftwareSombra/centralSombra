import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<bool> isUpdateAvailable() async {
  // Obtenha a versão atual do aplicativo.
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;
  debugPrint(currentVersion);

  // Consulte o Firestore para obter a versão mais recente.
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('config')
      .doc('latestVersion')
      .get();

  String? latestVersion =
      (snapshot.data() as Map<String, dynamic>)['versao atual'];
      debugPrint(latestVersion);

  // Compare as versões.
  return currentVersion.compareTo(latestVersion!) < 0;
}

Future<bool> isWebUpdateAvailable() async {
  // Obtenha a versão atual do aplicativo.
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;
  debugPrint(currentVersion);

  // Consulte o Firestore para obter a versão mais recente.
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('config')
      .doc('latestVersion')
      .get();

  String? latestVersion =
      (snapshot.data() as Map<String, dynamic>)['versao atual web'];
      debugPrint(latestVersion);

  // Compare as versões.
  return currentVersion.compareTo(latestVersion!) < 0;
}