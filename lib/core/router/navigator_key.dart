import 'package:flutter/material.dart';

/// A global [GlobalKey] for the root navigator so that deep-link callbacks
/// (e.g. notification taps that happen outside the widget tree) can navigate
/// to a route.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
