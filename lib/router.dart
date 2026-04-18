// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'game_internals/score.dart';
import 'play_session/play_session_screen.dart';
import 'settings/settings_screen.dart';
import 'style/my_transition.dart';
import 'style/palette.dart';
import 'win_game/win_game_screen.dart';

import 'city/city_screen.dart';
import 'calendar/calendar_screen.dart';
import 'shared/placeholder_screen.dart';


final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const PlaySessionScreen(key: Key('play session')),
      routes: [
        GoRoute(
          path: 'won',
          redirect: (context, state) {
            if (state.extra == null) {
              return '/';
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
          path: 'marketplace',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Marketplace'),
        ),
        GoRoute(
          path: 'cemetery',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Cemetery'),
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
