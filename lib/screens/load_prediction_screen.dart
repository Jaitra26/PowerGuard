import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/prediction_provider.dart';
import '../widgets/gauge_widget.dart';
import '../widgets/scale_on_press.dart';

class LoadPredictionScreen extends StatefulWidget {
  const LoadPredictionScreen({super.key});

  @override
  State<LoadPredictionScreen> createState() => _LoadPredictionScreenState();
}

class _LoadPredictionScreenState extends State<LoadPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tempController;
  late TextEditingController _humidityController;
  late TextEditingController _windController;
  late TextEditingController _solarController;
  late TextEditingController _loadController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PredictionProvider>();
    _tempController = TextEditingController(text: provider.temperature.toString());
    _humidityController = TextEditingController(text: provider.humidity.toString());
    _windController = TextEditingController(text: provider.windSpeed.toString());
    _solarController = TextEditingController(text: provider.solarIrradiance.toString());
    _loadController = TextEditingController(text: provider.currentLoad.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.history.isEmpty) {
        provider.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _tempController.dispose();
    _humidityController.dispose();
    _windController.dispose();
    _solarController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  void _triggerPrediction() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<PredictionProvider>();
      
      // Update values in provider first
      provider.setTemperature(double.parse(_tempController.text));
      provider.setHumidity(double.parse(_humidityController.text));
      provider.setWindSpeed(double.parse(_windController.text));
      provider.setSolarIrradiance(double.parse(_solarController.text));
      provider.setCurrentLoad(double.parse(_loadController.text));

      final success = await provider.performPrediction();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Load prediction completed successfully."),
              backgroundColor: AppTheme.success.withValues(alpha: 0.8),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Forecasting service error. Check local endpoint."),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppTheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        suffixStyle: AppTheme.geistMonoStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Value required";
        }
        if (double.tryParse(value) == null) {
          return "Enter numeric format";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PredictionProvider>(context);
    final res = provider.predictionResult;

    // Calculate percentage change for comparison badge
    double pctChange = 0.0;
    bool isIncrease = true;
    if (res != null) {
      final diff = res.predictedLoad - res.currentLoad;
      pctChange = (diff / res.currentLoad) * 100;
      isIncrease = pctChange >= 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Load Prediction",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. INPUT FORM CARD
            Card(
              color: AppTheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Environmental Parameters",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Enter current conditions to predict expected load.",
                        style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _tempController,
                        label: "Temperature",
                        icon: Icons.thermostat_outlined,
                        suffix: "°C",
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _humidityController,
                        label: "Humidity",
                        icon: Icons.water_drop_outlined,
                        suffix: "%",
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _windController,
                        label: "Wind Speed",
                        icon: Icons.air,
                        suffix: "km/h",
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _solarController,
                        label: "Solar Irradiance",
                        icon: Icons.wb_sunny_outlined,
                        suffix: "W/m²",
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _loadController,
                        label: "Current Load",
                        icon: Icons.electrical_services_outlined,
                        suffix: "MW",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. PREDICT BUTTON
            ScaleOnPress(
              onTap: provider.isPredicting ? null : _triggerPrediction,
              child: ElevatedButton(
                onPressed: provider.isPredicting ? null : _triggerPrediction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: provider.isPredicting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_graph, color: Colors.black, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "PREDICT LOAD",
                            style: TextStyle(letterSpacing: 1.5),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. RESULT CARD (visible with animated opacity when result is not null)
            AnimatedOpacity(
              opacity: res != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: res == null
                  ? const SizedBox.shrink()
                  : Card(
                      color: AppTheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.primary, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              "Prediction Result",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 16),
                            
                            // Glowing Custom Gauge Widget displaying predicted load
                            GaugeWidget(
                              value: res.predictedLoad,
                              min: 50.0,
                              max: 200.0,
                              label: "Forecasted Load",
                              unit: "MW",
                              color: AppTheme.primary,
                            ),
                            const SizedBox(height: 16),
                            
                            const Text(
                              "Expected load in next hour",
                              style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            
                            // Comparison Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isIncrease ? AppTheme.statusWarning : AppTheme.statusNormal).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: (isIncrease ? AppTheme.statusWarning : AppTheme.statusNormal).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 14,
                                    color: isIncrease ? AppTheme.statusWarning : AppTheme.statusNormal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${pctChange.abs().toStringAsFixed(1)}% vs current load",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isIncrease ? AppTheme.statusWarning : AppTheme.statusNormal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Confidence progress indicator
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Model Confidence",
                                      style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                                    ),
                                    Text(
                                      "${res.confidence.toStringAsFixed(1)}%",
                                      style: AppTheme.geistMonoStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: res.confidence / 100,
                                    minHeight: 6,
                                    backgroundColor: AppTheme.surfaceContainerLow,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: AppTheme.outlineVariant),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(Icons.info_outline, size: 12, color: AppTheme.onSurfaceVariant),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Prediction based on ML model. Actual values may vary.",
                                    style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // 4. HISTORY TABLE
            Card(
              color: AppTheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Predictions",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                        ),
                        if (res != null)
                          TextButton(
                            onPressed: () {
                              provider.clearResult();
                            },
                            child: const Text(
                              "Clear Screen",
                              style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    provider.isLoadingHistory
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: AppTheme.primary),
                            ),
                          )
                        : provider.history.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: Text(
                                    "No predictions run yet",
                                    style: TextStyle(color: AppTheme.onSurfaceVariant),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.history.length,
                                separatorBuilder: (_, _) => const Divider(color: AppTheme.outlineVariant, height: 16),
                                itemBuilder: (context, index) {
                                  final hist = provider.history[index];
                                  final timeLabel = DateFormat('HH:mm (MM-dd)').format(hist.timestamp);
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            timeLabel,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurface),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "In: ${hist.currentLoad} MW | Temp: ${hist.temperature}°C",
                                            style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${hist.predictedLoad} MW",
                                            style: AppTheme.geistMonoStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Conf: ${hist.confidence.toInt()}%",
                                            style: const TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
