# PowerGuard 🛡️⚡

PowerGuard is a professional-grade, cross-platform **Smart Grid Telemetry, Anomaly Detection, and Load Forecasting Dashboard** built with Flutter. Designed for grid administrators and utility operators, it provides real-time visibility into power grids, transformer stations, and consumer energy consumption patterns while utilizing predictive modeling to forecast grid demand.

---

## 🌟 Key Features

*   **Real-Time Grid Telemetry & Diagnostics:** Monitor active power load, reactive power, power factor, line voltage, and system frequency.
*   **Predictive AI/ML Load Forecasting:** Dynamic environment-aware demand forecasting. Users can adjust parameters (temperature, humidity, wind speed, solar irradiance) to simulate and forecast grid load.
*   **Grid Anomaly & Theft Detection:** Immediate visual alerts for Critical Faults, Voltage Sags, Transformer Overloads, and potential Electricity Theft (via node-telemetry mismatches).
*   **Interactive Analytics & Data Visualization:** High-performance historical data rendering using `fl_chart`, depicting daily and weekly load profiles, power factors, and reactive curves.
*   **Cloud Synchronization & Auth:** Secure Firebase Authentication (Email/Password, Google Sign-in) paired with real-time Firestore database synchronization.
*   **Premium Glassmorphic Design:** Built in compliance with Material 3 design systems, featuring clean dark/light UI, custom gauge displays, active state micro-animations, and fluid transitions.

---

## 🛠️ Technology Stack

*   **Framework:** [Flutter](https://flutter.dev) (SDK `^3.12.1`)
*   **Language:** [Dart](https://dart.dev)
*   **State Management:** `provider` (MultiProvider architecture)
*   **Routing:** `go_router` (declarative path routing)
*   **Charts & Visuals:** `fl_chart` (custom custom-rendered vector charts)
*   **Database & Auth:** Firebase Core, Cloud Firestore, Firebase Auth, Google Sign-In
*   **UI/UX Enhancements:** `shimmer` (skeleton loaders), `google_fonts` (Outfit & Geist Mono), and custom performance-tuned telemetry gauge widgets.

---

## 🚀 Getting Started

### Prerequisites

To run PowerGuard locally, ensure you have:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (Stable channel recommended)
*   Dart SDK (comes bundled with Flutter)
*   An Android Emulator, iOS Simulator, or Desktop Environment configured.

### Installation

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Jaitra26/PowerGuard.git
    cd PowerGuard/PowerGuard-main
    ```

2.  **Fetch Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the App:**
    ```bash
    flutter run
    ```

### 🧠 Forecasting Backend Setup (Optional)

The application attempts to interface with a machine learning load forecasting service (configured in [api_service.dart](file:///c:/Users/HIREN/Downloads/PowerGuard-main/PowerGuard-main/lib/services/api_service.dart)):
*   **Emulator Path:** `http://10.0.2.2:5000/predict`
*   **Local Web/Desktop Path:** `http://localhost:5000/predict`

If a backend is not detected or fails to respond within 1.5 seconds, the app gracefully falls back to a highly realistic **telemetry emulation algorithm** so dashboard interaction is never interrupted.

To configure your own prediction server:
1. Create a Flask/FastAPI endpoint listening on port `5000` at `/predict`.
2. Accept a `POST` request with JSON containing:
   ```json
   {
     "temperature": 32.5,
     "humidity": 65.0,
     "wind_speed": 12.4,
     "solar_irradiance": 750.0,
     "current_load": 140.0
   }
   ```
3. Return the predicted load and confidence:
   ```json
   {
     "predicted_load": 158.4,
     "confidence": 94.5
   }
   ```

---

## 📂 Project Architecture

The application is structured following clean, decoupled MVC/MVVM principles:

```text
lib/
├── models/         # Telemetry, Alert, User, and Prediction data models
├── providers/      # Application state handlers (Auth, Energy, and Prediction)
├── screens/        # UI Page components (Dashboard, Analytics, Predictor, Profile, Auth)
├── services/       # External communications layer (Firebase, REST APIs)
├── theme/          # App theme (Color palettes, fonts, borders, global decoration)
└── widgets/        # Reusable dashboard components (Gauge widgets, Custom charts, Alert tiles)
```

---

## 🔒 License

Distributed under the MIT License. See `LICENSE` for more information.
