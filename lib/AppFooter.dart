import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Powered by ",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                ),
          ),
          Image.asset(
            "assets/AiAllyLogo.png", // 👈 yaha apna footer image daal
            height: 30,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
