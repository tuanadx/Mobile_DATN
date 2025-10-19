@echo off
echo Getting SHA-1 fingerprint for Google Sign-In setup...
echo.

cd android
echo Running gradle signingReport...
call gradlew signingReport

echo.
echo Copy the SHA-1 fingerprint from the debug section above.
echo Paste it into Google Cloud Console when creating OAuth 2.0 credentials.
echo.
pause


