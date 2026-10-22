import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upi_intent/upi_intent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPI Intent Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _vpaController    = TextEditingController(text: 'merchant@upi');
  final _nameController   = TextEditingController(text: 'Yash Stores');
  final _amountController = TextEditingController(text: '1');
  final _noteController   = TextEditingController(text: 'Test Payment');

  UpiResponse? _response;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _vpaController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _response = null;
    });

    try {
      final res = await UpiIntent.pay(
        context: context,
        payment: UpiPayment(
          payeeVpa: _vpaController.text.trim(),
          payeeName: _nameController.text.trim().isEmpty
              ? 'Merchant'
              : _nameController.text.trim(),
          amount: double.tryParse(_amountController.text.trim()),
          transactionNote: _noteController.text.trim(),
          transactionRefId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      setState(() => _response = res);
    } on UpiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: bg,
            elevation: 0,
            pinned: true,
            expandedHeight: 96,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'upi_intent',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0A0A0A),
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    'Plugin Demo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            actions: const [],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Amount Card ──────────────────────────────────────────
                _AmountCard(controller: _amountController),
                const SizedBox(height: 12),

                // ── Pay To Form ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAY TO',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        ctrl: _vpaController,
                        hint: 'UPI ID  (e.g. name@upi)',
                        icon: Icons.alternate_email_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        ctrl: _nameController,
                        hint: 'Payee Name',
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        ctrl: _noteController,
                        hint: 'Note (optional)',
                        icon: Icons.notes_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Banners ──────────────────────────────────────────────
                if (_error != null) _ErrorBanner(_error!, isDark),
                if (_response != null) _ResponseBanner(_response!, isDark),

                // ── Pay Button ───────────────────────────────────────────
                _PayButton(
                  loading: _loading,
                  isDark: isDark,
                  onTap: _pay,
                ),
                const SizedBox(height: 28),

                // ── How it works ─────────────────────────────────────────
                Text(
                  'HOW IT WORKS',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    children: [
                      _Step(
                        number: '01',
                        title: 'Call UpiIntent.pay()',
                        subtitle: 'Pass payee VPA, name and amount',
                        isDark: isDark,
                      ),
                      _Divider(isDark),
                      _Step(
                        number: '02',
                        title: 'App picker opens',
                        subtitle: 'User selects their preferred UPI app',
                        isDark: isDark,
                      ),
                      _Divider(isDark),
                      _Step(
                        number: '03',
                        title: 'Get UpiResponse',
                        subtitle:
                            'Parse status, TxnID and verify on your backend',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Amount Card ──────────────────────────────────────────────────────────────
class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  const _AmountCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('₹',
              style: TextStyle(
                  color: Colors.white70, fontSize: 34, fontWeight: FontWeight.w300)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.white30),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Text(
            'INR',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pay Button ───────────────────────────────────────────────────────────────
class _PayButton extends StatelessWidget {
  final bool loading;
  final bool isDark;
  final VoidCallback onTap;
  const _PayButton({required this.loading, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Light → black button | Dark → white button
    final bgColor = loading
        ? (isDark ? Colors.white24 : Colors.grey.shade400)
        : (isDark ? Colors.white : const Color(0xFF0A0A0A));
    final textColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isDark ? Colors.black54 : Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, color: textColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Pay with UPI',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Step Row (How it works) ──────────────────────────────────────────────────
class _Step extends StatelessWidget {
  final String number, title, subtitle;
  final bool isDark;
  const _Step({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider(this.isDark);
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.07),
    );
  }
}

// ─── Response Banner ──────────────────────────────────────────────────────────
class _ResponseBanner extends StatelessWidget {
  final UpiResponse response;
  final bool isDark;
  const _ResponseBanner(this.response, this.isDark);

  @override
  Widget build(BuildContext context) {
    final ok = response.isSuccess;
    final color =
        ok ? const Color(0xFF16A34A) : const Color(0xFFD97706);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ok
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                ok ? 'Payment Successful' : 'Status: ${response.status.name}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (response.transactionId != null) ...[
            const SizedBox(height: 8),
            _KV('TxnID', response.transactionId!, isDark),
          ],
          if (response.approvalRefNo != null)
            _KV('Ref', response.approvalRefNo!, isDark),
          const SizedBox(height: 8),
          Text(
            '⚠️  Verify TxnID on your backend before confirming.',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  final bool isDark;
  const _ErrorBanner(this.msg, this.isDark);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KV Row ───────────────────────────────────────────────────────────────────
class _KV extends StatelessWidget {
  final String k, v;
  final bool isDark;
  const _KV(this.k, this.v, this.isDark);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$k: ',
            style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38)),
        Expanded(
          child: Text(
            v,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Text Field ───────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const _Field({
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0A0A0A),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white24 : Colors.black26,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon,
            size: 18,
            color: isDark ? Colors.white38 : Colors.black38),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }
}
