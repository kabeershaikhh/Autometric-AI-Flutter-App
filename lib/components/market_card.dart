import 'package:flutter/material.dart';

class MarketCard extends StatelessWidget {
  const MarketCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEE6FF),
            Color(0xFFF8F5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD8C9FF),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //////////////////////////////////////////////////////
          /// TOP
          //////////////////////////////////////////////////////

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF7C4DFF),
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Market Outlook",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2342),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Updated Today",
                      style: TextStyle(
                        color: Color(0xFF7B7198),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "2.8%",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          //////////////////////////////////////////////////////
          /// DESCRIPTION
          //////////////////////////////////////////////////////

          const Text(
            "Used car prices remain stable this week with increased demand for SUVs and hatchbacks across major Pakistani cities.",
            style: TextStyle(
              color: Color(0xFF5F5874),
              height: 1.6,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          //////////////////////////////////////////////////////
          /// STATS
          //////////////////////////////////////////////////////

          Row(
            children: const [
              Expanded(
                child: _InfoTile(
                  icon: Icons.location_on_outlined,
                  value: "15+",
                  title: "Cities",
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.directions_car_outlined,
                  value: "10k+",
                  title: "Cars",
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.analytics_outlined,
                  value: "98%",
                  title: "Predictions",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _InfoTile({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF7C4DFF),
            size: 22,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2A2342),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7B7198),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}