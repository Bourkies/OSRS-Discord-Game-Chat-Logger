@echo off
REM This script runs the OSRS Clan Reporter

echo Running OSRS Clan Reporter...
echo.

REM Execute the python script located in the src folder
python src/run_all_etl.py

echo.
echo Script has finished.
pause
