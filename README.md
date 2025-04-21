#  Object Detection with EfficientNet-Lite0 in Flutter

This Flutter application demonstrates how to perform **real-time image classification** using the **EfficientNet-Lite0** model (`efficientnet-lite0-fp32.tflite`) via the lightweight **[TFLite](https://pub.dev/packages/tflite)** plugin.

---

##  About the Model

### EfficientNet-Lite0 (FP32)

- EfficientNet is a family of convolutional neural networks developed by Google AI.
- It achieves **state-of-the-art accuracy with fewer parameters and faster inference** by optimizing depth, width, and resolution using a compound scaling method.
- The **Lite0 version** is specifically designed for mobile and edge devices.
- This project uses the **FP32 (32-bit floating point)** quantized `.tflite` version of the model for higher accuracy at the cost of slightly more processing.

 [More about EfficientNet models](https://tfhub.dev/s?q=efficientnet](https://github.com/RangiLyu/EfficientNet-Lite))

---

##  Features

- Capture image from camera
- Run classification locally using TFLite
- Uses EfficientNet-Lite0 model for accurate predictions
- Displays label with confidence score
- Modern UI with gradients and dark mode support

---

## How to Run

Follow these steps to run the project locally:

```bash
# 1. Clone the repository
git clone https://github.com/an90ass/ObjDet-Flutter.git

# 2. Navigate to the project directory
cd ObjDet-Flutter/objdet

# 3. Get the dependencies
flutter pub get

# 4. Run the app on an emulator or connected device
flutter run
