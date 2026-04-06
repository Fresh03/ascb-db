#!/bin/bash

echo "========================================"
echo "    ASCB Database Management System"
echo "========================================"
echo

echo "Checking Java installation..."
if ! command -v java &> /dev/null; then
    echo "ERROR: Java is not installed or not in PATH."
    echo "Please install Java 21 and add it to your PATH."
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Checking Maven installation..."
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed or not in PATH."
    echo "Please install Maven and add it to your PATH."
    read -p "Press Enter to exit..."
    exit 1
fi

echo
echo "Starting ASCB Database System..."
echo

cd "$(dirname "$0")/ascb-db"

echo "[1/2] Starting Backend Server..."
echo "Backend will run on: http://localhost:8080"
# Start backend in background
cd backend
mvn spring-boot:run &
BACKEND_PID=$!
cd ..

echo "Waiting 15 seconds for backend to initialize..."
sleep 15

echo
echo "[2/2] Starting Frontend Application..."
echo "Frontend GUI will open in a new window."
# Start frontend
cd frontend
mvn -DskipTests javafx:run &
FRONTEND_PID=$!

echo
echo "========================================"
echo "    System Started Successfully!"
echo "========================================"
echo
echo "- Backend API: http://localhost:8080"
echo "- Frontend GUI: Should open automatically"
echo
echo "Press Ctrl+C to stop all services..."

# Wait for user interrupt
trap "echo 'Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT
wait