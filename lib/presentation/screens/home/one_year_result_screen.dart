import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OneYearResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const OneYearResultScreen({super.key, required this.resultData});

  String _formatCurrency(dynamic value) {
    if (value is num) {
      String str = value.abs().toStringAsFixed(0);
      str = str.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
      return value < 0 ? '-₹ $str' : '₹ $str';
    }
    return '₹ ${value ?? 0}';
  }

  String _formatCamelCase(String text) {
    if (text.isEmpty) return text;

    String result = text.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => ' ${m.group(0)}',
    );

    result = result[0].toUpperCase() + result.substring(1);
    result = result.replaceAll('_', ' ');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("3-Year Financial Projection"),
          centerTitle: true,
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 4,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Year 1"),
              Tab(text: "Year 2"),
              Tab(text: "Year 3"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildYearView("firstYear"),
            _buildYearView("secondYear"),
            _buildYearView("thirdYear"),
          ],
        ),
      ),
    );
  }

  Widget _buildYearView(String yearKey) {
    final year = resultData[yearKey];
    if (year == null) {
      return const Center(child: Text("No data available"));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profit Summary Card with Pie Chart
          _buildProfitSummaryCard(year),
          const SizedBox(height: 20),

          // Key Metrics Cards
          _buildKeyMetricsCards(year),
          const SizedBox(height: 24),

          // Expandable Sections
          ExpandableAccountSection(
            title: "Trading Account",
            subtitle: "Revenue & Cost of Goods Sold",
            icon: Icons.trending_up,
            color: Colors.blue.shade700,
            data: year["oneYearTrading"]?["yearOne"] ?? {},
          ),
          const SizedBox(height: 12),

          ExpandableAccountSection(
            title: "Profit & Loss",
            subtitle: "Operational Performance",
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF1A237E),
            data: year["pl"]?["profitLoss"] ?? {},
          ),
          const SizedBox(height: 12),

          ExpandableAccountSection(
            title: "Balance Sheet - Assets",
            subtitle: "Financial Position",
            icon: Icons.business_center,
            color: Colors.purple.shade700,
            data: year["balanceSheet"]?["bs"]?["assets"] ?? {},
          ),
          const SizedBox(height: 12),

          ExpandableAccountSection(
            title: "Balance Sheet - Liabilities",
            subtitle: "Financial Obligations",
            icon: Icons.assignment,
            color: Colors.orange.shade700,
            data: year["balanceSheet"]?["bs"]?["liabilities"] ?? {},
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfitSummaryCard(Map<String, dynamic> year) {
    final trading = year["oneYearTrading"]?["yearOne"] ?? {};
    final pl = year["pl"]?["profitLoss"] ?? {};
    final netProfit = (pl["netProfit"] ?? 0) as num;
    final isProfit = netProfit >= 0;
    final sales = trading["sales"] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 110,
            width: 110,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 4,
                centerSpaceRadius: 38,
                sections: [
                  PieChartSectionData(
                    value: sales.abs().toDouble(),
                    color: const Color(0xFFFFA000),
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (sales - netProfit).abs().toDouble(),
                    color: const Color(0xFF1A237E),
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: netProfit.abs().toDouble(),
                    color: isProfit
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade700,
                    radius: 18,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProfit ? "Net Profit" : "Net Loss",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(netProfit),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isProfit
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isProfit
                      ? "Business is Profitable"
                      : "Business is in Loss",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCards(Map<String, dynamic> year) {
    final trading = year["oneYearTrading"]?["yearOne"] ?? {};
    final pl = year["pl"]?["profitLoss"] ?? {};
    final netProfit = (pl["netProfit"] ?? 0) as num;
    final isProfit = netProfit >= 0;
    final sales = trading["sales"] ?? 0;
    final grossProfit = trading["grossProfitLoss"] ?? 0;
    final totalAssets = year["balanceSheet"]?["totalAssets"] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Sales",
                sales,
                Icons.trending_up,
                Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                "Gross Profit",
                grossProfit,
                Icons.attach_money,
                Colors.orange.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Net Profit",
                netProfit,
                Icons.account_balance_wallet,
                isProfit ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                "Total Assets",
                totalAssets,
                Icons.business,
                Colors.purple.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, dynamic value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New Widget for Expandable Sections
class ExpandableAccountSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> data;

  const ExpandableAccountSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.data,
  });

  @override
  State<ExpandableAccountSection> createState() => _ExpandableAccountSectionState();
}

class _ExpandableAccountSectionState extends State<ExpandableAccountSection> {
  bool _isExpanded = false;

  String _formatCurrency(dynamic value) {
    if (value is num) {
      String str = value.abs().toStringAsFixed(0);
      str = str.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
      return value < 0 ? '-₹ $str' : '₹ $str';
    }
    return '₹ ${value ?? 0}';
  }

  String _formatCamelCase(String text) {
    if (text.isEmpty) return text;

    String result = text.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => ' ${m.group(0)}',
    );

    result = result[0].toUpperCase() + result.substring(1);
    result = result.replaceAll('_', ' ');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header - Always visible
          ListTile(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            leading: Icon(widget.icon, color: widget.color),
            title: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.color,
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  ...widget.data.entries.map((e) {
                    final num val = e.value is num ? e.value : 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'To ${_formatCamelCase(e.key)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            _formatCurrency(val),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: val >= 0
                                  ? const Color(0xFF002D72)
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}