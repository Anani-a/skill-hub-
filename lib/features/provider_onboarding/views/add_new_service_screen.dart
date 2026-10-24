import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../providers/provider_onboarding_provider.dart';

class AddNewServiceScreen extends ConsumerStatefulWidget {
  const AddNewServiceScreen({super.key});

  @override
  ConsumerState<AddNewServiceScreen> createState() => _AddNewServiceScreenState();
}

class _AddNewServiceScreenState extends ConsumerState<AddNewServiceScreen> {
  final _serviceNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '300');
  final _durationCtrl = TextEditingController(text: '60 mins');
  String _selectedCategory = 'Home Services & Cleaning';

  final List<String> _categories = [
    'Home Services & Cleaning',
    'Electrical Repair',
    'Plumbing & Water',
    'Painting & Decorating',
    'Appliance Maintenance',
  ];

  final List<String> _samplePhotoEmojis = ['🛋️', '🧹', '✨'];

  @override
  void dispose() {
    _serviceNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _saveService(String activeLang) {
    final title = _serviceNameCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            activeLang == 'am' ? 'እባክዎ የአገልግሎት ስም ያስገቡ' : 'Please enter a service name',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final priceStr = _priceCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final durationStr = _durationCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    final price = double.tryParse(priceStr) ?? 300.0;
    final duration = int.tryParse(durationStr) ?? 60;

    ref.read(providerOnboardingProvider.notifier).addService(
          OnboardingServiceItem(
            id: 's_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            priceEtb: price,
            durationMinutes: duration,
            emoji: '🛋️',
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activeLang == 'am' ? 'አገልግሎት በተሳካ ሁኔታ ተaddedል!' : 'Service added successfully!',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      activeLang == 'am' ? 'አዲስ አገልግሎት ያክሉ' : 'Add New Service',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Service Name
                    _buildLabel(activeLang == 'am' ? 'የአገልግሎት ስም' : 'Service Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _serviceNameCtrl,
                      hint: 'e.g. Sofa Cleaning',
                    ),

                    const SizedBox(height: 20),

                    // 2. Category Dropdown
                    _buildLabel(activeLang == 'am' ? 'ምድብ' : 'Category'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outlineLighter),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor: AppTheme.bgSurface,
                          isExpanded: true,
                          hint: Text(activeLang == 'am' ? 'ምድብ ይምረጡ' : 'Select category'),
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Description
                    _buildLabel(activeLang == 'am' ? 'መግለጫ' : 'Description'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionCtrl,
                      maxLines: 4,
                      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: activeLang == 'am' ? 'ስለ አገልግሎቱ ይግለጹ' : 'Describe your service',
                        hintStyle: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                        filled: true,
                        fillColor: AppTheme.inputBg,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.outlineLighter),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. Price & Duration Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(activeLang == 'am' ? 'ዋጋ (ETB)' : 'Price (ETB)'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _priceCtrl,
                                hint: '300',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(activeLang == 'am' ? 'ጊዜ' : 'Duration'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _durationCtrl,
                                hint: '60 mins',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // 5. Add Photos Section
                    _buildLabel(activeLang == 'am' ? 'ፎቶዎችን ያክሉ' : 'Add Photos'),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ..._samplePhotoEmojis.map((emoji) {
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.outlineLight),
                              ),
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 32)),
                              ),
                            );
                          }),

                          // Plus Button Card to add photo
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _samplePhotoEmojis.add('📸');
                              });
                            },
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppTheme.bgSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.outlineLighter, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: AppTheme.primary,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action Button: Save Service
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _saveService(activeLang),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    activeLang == 'am' ? 'አገልግሎት አስቀምጥ' : 'Save Service',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
        filled: true,
        fillColor: AppTheme.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.outlineLighter),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
