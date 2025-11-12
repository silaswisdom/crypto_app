# crypto_app

A modern, responsive Flutter application for real-time cryptocurrency tracking, fetching data from the CoinGecko API.

Core Features

Live Data: Tracks the top 50 cryptocurrencies with real-time price, volume, and 24h change.

Price Charts: Detailed 7-day historical price charts powered by fl_chart.

Favorites: Local storage for saving favorite coins using shared_preferences.

Responsive Design: Optimized for both mobile and tablet, featuring a clean dark theme.

Project Structure Highlight: Data fetching is handled by coingecko_service.dart, UI screens are in the screens/ folder, and persistent data (favorites) is managed by favorites.dart.

Quick Setup

This project is a standard Flutter application.

Prerequisites

Flutter SDK (v3.0 or higher recommended).

The application uses the free CoinGecko API (no API key required).

Step 1: Install Dependencies

Add the following required packages to your pubspec.yaml file:

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0 
  fl_chart: ^0.68.0 
  shared_preferences: ^2.2.3


Then, run:

flutter pub get


Step 2: Run

Execute the application on your desired device or emulator:

flutter run
