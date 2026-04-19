import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_budget_tracker/widgets/app_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onCurrencySelected,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final Function(String) onCurrencySelected;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _pulseController;
  late final TextEditingController _searchController;

  String _selectedCurrency = 'USD';
  String _query = '';

  static const List<(String, String, String)> _currencies =
      <(String, String, String)>[
        ('USD', 'US Dollar', '\$'),
        ('EUR', 'Euro', '€'),
        ('GBP', 'British Pound', '£'),
        ('JPY', 'Japanese Yen', '¥'),
        ('INR', 'Indian Rupee', '₹'),
        ('AED', 'UAE Dirham', 'AED'),
        ('AFN', 'Afghan Afghani', 'AFN'),
        ('ALL', 'Albanian Lek', 'ALL'),
        ('AMD', 'Armenian Dram', 'AMD'),
        ('ANG', 'Netherlands Antillean Guilder', 'ANG'),
        ('AOA', 'Angolan Kwanza', 'AOA'),
        ('ARS', 'Argentine Peso', 'ARS'),
        ('AWG', 'Aruban Florin', 'AWG'),
        ('AUD', 'Australian Dollar', '\$'),
        ('AZN', 'Azerbaijani Manat', 'AZN'),
        ('BAM', 'Bosnia-Herzegovina Mark', 'BAM'),
        ('BBD', 'Barbadian Dollar', 'BBD'),
        ('BDT', 'Bangladeshi Taka', '৳'),
        ('BGN', 'Bulgarian Lev', 'BGN'),
        ('BHD', 'Bahraini Dinar', 'BHD'),
        ('BIF', 'Burundian Franc', 'BIF'),
        ('BMD', 'Bermudan Dollar', 'BMD'),
        ('BND', 'Brunei Dollar', 'BND'),
        ('BOB', 'Bolivian Boliviano', 'BOB'),
        ('BRL', 'Brazilian Real', 'R\$'),
        ('BSD', 'Bahamian Dollar', 'BSD'),
        ('BTN', 'Bhutanese Ngultrum', 'BTN'),
        ('BWP', 'Botswanan Pula', 'BWP'),
        ('BYN', 'Belarusian Ruble', 'BYN'),
        ('BZD', 'Belize Dollar', 'BZD'),
        ('CAD', 'Canadian Dollar', '\$'),
        ('CDF', 'Congolese Franc', 'CDF'),
        ('CHF', 'Swiss Franc', 'CHF'),
        ('CLP', 'Chilean Peso', 'CLP'),
        ('CNY', 'Chinese Yuan', 'CNY'),
        ('COP', 'Colombian Peso', 'COP'),
        ('CRC', 'Costa Rican Colon', 'CRC'),
        ('CUP', 'Cuban Peso', 'CUP'),
        ('CZK', 'Czech Koruna', 'CZK'),
        ('DKK', 'Danish Krone', 'DKK'),
        ('DOP', 'Dominican Peso', 'DOP'),
        ('DZD', 'Algerian Dinar', 'DZD'),
        ('EGP', 'Egyptian Pound', 'EGP'),
        ('ETB', 'Ethiopian Birr', 'ETB'),
        ('FJD', 'Fijian Dollar', 'FJD'),
        ('GEL', 'Georgian Lari', 'GEL'),
        ('GHS', 'Ghanaian Cedi', 'GHS'),
        ('GMD', 'Gambian Dalasi', 'GMD'),
        ('GNF', 'Guinean Franc', 'GNF'),
        ('GTQ', 'Guatemalan Quetzal', 'GTQ'),
        ('HKD', 'Hong Kong Dollar', 'HKD'),
        ('HNL', 'Honduran Lempira', 'HNL'),
        ('HRK', 'Croatian Kuna', 'HRK'),
        ('HUF', 'Hungarian Forint', 'HUF'),
        ('IDR', 'Indonesian Rupiah', 'IDR'),
        ('ILS', 'Israeli New Shekel', 'ILS'),
        ('IQD', 'Iraqi Dinar', 'IQD'),
        ('IRR', 'Iranian Rial', 'IRR'),
        ('ISK', 'Icelandic Krona', 'ISK'),
        ('JMD', 'Jamaican Dollar', 'JMD'),
        ('JOD', 'Jordanian Dinar', 'JOD'),
        ('KES', 'Kenyan Shilling', 'KES'),
        ('KGS', 'Kyrgystani Som', 'KGS'),
        ('KHR', 'Cambodian Riel', 'KHR'),
        ('KRW', 'South Korean Won', '₩'),
        ('KWD', 'Kuwaiti Dinar', 'KWD'),
        ('KZT', 'Kazakhstani Tenge', 'KZT'),
        ('LAK', 'Laotian Kip', 'LAK'),
        ('LBP', 'Lebanese Pound', 'LBP'),
        ('LKR', 'Sri Lankan Rupee', 'LKR'),
        ('MAD', 'Moroccan Dirham', 'MAD'),
        ('MDL', 'Moldovan Leu', 'MDL'),
        ('MGA', 'Malagasy Ariary', 'MGA'),
        ('MKD', 'Macedonian Denar', 'MKD'),
        ('MMK', 'Myanmar Kyat', 'MMK'),
        ('MNT', 'Mongolian Tugrik', 'MNT'),
        ('MOP', 'Macanese Pataca', 'MOP'),
        ('MUR', 'Mauritian Rupee', 'MUR'),
        ('MVR', 'Maldivian Rufiyaa', 'MVR'),
        ('MXN', 'Mexican Peso', 'MXN'),
        ('MYR', 'Malaysian Ringgit', 'MYR'),
        ('NAD', 'Namibian Dollar', 'NAD'),
        ('NGN', 'Nigerian Naira', 'NGN'),
        ('NOK', 'Norwegian Krone', 'NOK'),
        ('NPR', 'Nepalese Rupee', 'NPR'),
        ('NZD', 'New Zealand Dollar', 'NZD'),
        ('OMR', 'Omani Rial', 'OMR'),
        ('PAB', 'Panamanian Balboa', 'PAB'),
        ('PEN', 'Peruvian Sol', 'PEN'),
        ('PHP', 'Philippine Peso', 'PHP'),
        ('PKR', 'Pakistani Rupee', 'PKR'),
        ('PLN', 'Polish Zloty', 'PLN'),
        ('QAR', 'Qatari Riyal', 'QAR'),
        ('RON', 'Romanian Leu', 'RON'),
        ('RSD', 'Serbian Dinar', 'RSD'),
        ('RUB', 'Russian Ruble', 'RUB'),
        ('SAR', 'Saudi Riyal', 'SAR'),
        ('SEK', 'Swedish Krona', 'SEK'),
        ('SGD', 'Singapore Dollar', 'SGD'),
        ('THB', 'Thai Baht', 'THB'),
        ('TRY', 'Turkish Lira', 'TRY'),
        ('TWD', 'New Taiwan Dollar', 'TWD'),
        ('UAH', 'Ukrainian Hryvnia', 'UAH'),
        ('UGX', 'Ugandan Shilling', 'UGX'),
        ('UYU', 'Uruguayan Peso', 'UYU'),
        ('UZS', 'Uzbekistani Som', 'UZS'),
        ('VND', 'Vietnamese Dong', 'VND'),
        ('XOF', 'West African CFA Franc', 'XOF'),
        ('YER', 'Yemeni Rial', 'YER'),
        ('ZAR', 'South African Rand', 'ZAR'),
        ('ZMW', 'Zambian Kwacha', 'ZMW'),
      ];

  List<(String, String, String)> get _filteredCurrencies {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _currencies;
    return _currencies.where((currency) {
      final (code, name, _) = currency;
      return code.toLowerCase().contains(query) ||
          name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _submitCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency', _selectedCurrency);
      await prefs.setBool('first_launch_completed', true);

      if (!mounted) return;

      // Parent switches app root from welcome to home.
      widget.onCurrencySelected(_selectedCurrency);
    } catch (e) {
      debugPrint('Error saving currency: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        isDark: isDark,
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: widget.onToggleTheme,
                        icon: Icon(
                          widget.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[
                            const Color(0xFF2B6EF7),
                            const Color(0xFF00E4FF),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icon.png',
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to SmartBudget',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFEAF8FF)
                          : const Color(0xFF0E2453),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your currency to continue',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? const Color(0xFF98D6FF)
                          : const Color(0xFF4D689B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search currency by code or name',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.85),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _filteredCurrencies.isEmpty
                        ? Center(
                            child: Text(
                              'No currency found',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFA1BCD5)
                                    : const Color(0xFF6A81AA),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _filteredCurrencies.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final (code, name, symbol) =
                                  _filteredCurrencies[index];
                              final selected = _selectedCurrency == code;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () =>
                                      setState(() => _selectedCurrency = code),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: selected
                                          ? const Color(0xFF2B6EF7).withValues(
                                              alpha: isDark ? 0.28 : 0.14,
                                            )
                                          : isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF2B6EF7)
                                            : isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.12,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.55,
                                              ),
                                        width: selected ? 2 : 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selected
                                                ? const Color(0xFF2B6EF7)
                                                : (isDark
                                                      ? const Color(0xFF1A2848)
                                                      : const Color(
                                                          0xFFE4EEFF,
                                                        )),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            symbol,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? Colors.white
                                                  : (isDark
                                                        ? const Color(
                                                            0xFFEAF8FF,
                                                          )
                                                        : const Color(
                                                            0xFF0E2453,
                                                          )),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                code,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: selected
                                                      ? const Color(0xFF2B6EF7)
                                                      : (isDark
                                                            ? const Color(
                                                                0xFFEAF8FF,
                                                              )
                                                            : const Color(
                                                                0xFF0E2453,
                                                              )),
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? const Color(0xFFA1BCD5)
                                                      : const Color(0xFF6A81AA),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF2B6EF7),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2B6EF7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _submitCurrency,
                      child: Text(
                        'Continue with $_selectedCurrency',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can change your currency later in settings',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFA1BCD5)
                          : const Color(0xFF6A81AA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
