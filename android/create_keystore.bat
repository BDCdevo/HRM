@echo off
cd "%~dp0app"

echo Creating keystore for Google Play App Signing...
echo.

keytool -genkey -v ^
  -storetype JKS ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000 ^
  -alias upload ^
  -keystore upload-keystore.jks ^
  -storepass "HrmApp2024Secure" ^
  -keypass "HrmApp2024Secure" ^
  -dname "CN=HRM App, OU=Development, O=BDC, L=Cairo, ST=Cairo, C=EG"

echo.
echo ======================================
echo Keystore created successfully!
echo ======================================
echo File: android/app/upload-keystore.jks
echo Alias: upload
echo Password: HrmApp2024Secure
echo ======================================
echo.
echo IMPORTANT: Save this information securely!
echo.
pause
