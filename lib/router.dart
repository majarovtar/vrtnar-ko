// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'calendar/calendar_screen.dart';
import 'city/city_screen.dart';
import 'city/city_windows_screen.dart';
import 'city/friend_home_screen.dart';
import 'city/graveyard_screen.dart';
import 'game_internals/score.dart';
import 'main_menu/main_menu_screen.dart';
import 'play_session/play_session_screen.dart';
import 'settings/settings_screen.dart';
import 'shared/placeholder_screen.dart';
import 'style/my_transition.dart';
import 'style/palette.dart';
import 'win_game/win_game_screen.dart';


final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const MainMenuScreen(key: Key('main menu')),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) =>
          const PlaySessionScreen(key: Key('play session')),
      routes: [
        GoRoute(
          path: 'won',
          redirect: (context, state) {
            if (state.extra == null) {
              return '/home';
            }
            return null;
          },
          pageBuilder: (context, state) {
            final map = state.extra! as Map<String, dynamic>;
            final score = map['score'] as Score;

            return buildMyTransition<void>(
              key: const ValueKey('won'),
              color: context.watch<Palette>().backgroundPlaySession,
              child: WinGameScreen(
                score: score,
                key: const Key('win game'),
              ),
            );
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) =>
              const SettingsScreen(key: Key('settings')),
        ),

        GoRoute(
          path: 'calendar',
          builder: (context, state) => const CalendarScreen(key: Key('calendar')),
        ),
        GoRoute(
          path: 'city',
          builder: (context, state) => const CityScreen(key: Key('city')),
        ),
        GoRoute(
          path: 'city-windows',
          builder: (context, state) => const CityWindowsScreen(),
        ),
        GoRoute(
          path: 'friend-home/:friendId',
          builder: (context, state) {
            final friendId = state.pathParameters['friendId'] ?? '';
            final names = {
              'anna': 'Anna',
              'maria': 'Maria',
              'lucas': 'Lucas',
            };
            return FriendHomeScreen(friendName: names[friendId] ?? 'Friend');
          },
        ),
        GoRoute(
          path: 'marketplace',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Marketplace'),
        ),
        GoRoute(
          path: 'cemetery',
          builder: (context, state) =>
              const GraveyardScreen(),
        ),
        GoRoute(
          path: 'friend-balcony',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Friend Balcony'),
        ),

      ],
    ),
  ],
);
