import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.error, this.homePath = '/'});

  /// Pass `state.error` from GoRouter's errorBuilder.
  final Exception? error;

  /// Route to navigate to when tapping "Go Home".
  final String homePath;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withAOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -140,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withAOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // 404 display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '4',
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 96,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.card,
                          border: Border.all(
                            color: AppTheme.primary.withAOpacity(0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAOpacity(0.35),
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 44,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        '4',
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 96,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withAOpacity(0.5),
                      ),
                    ),
                    child: const Text(
                      'PAGE NOT FOUND',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'LOOKS LIKE YOU SKIPPED A REP',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      letterSpacing: 1.5,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'The page you\'re looking for doesn\'t exist\n'
                    'or has been moved.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Text(
                        (error as GoException).message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],

                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () => context.go(homePath),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('GO HOME'),
                  ),

                  if (context.canPop()) ...[
                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(homePath);
                        }
                      },
                      child: const Text('GO BACK'),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
