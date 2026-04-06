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
PROJECT_DIR=$(pwd)
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

echo "[1/2] Starting Backend Server..."
echo "Backend will run on: http://localhost:8080"

# Start backend in background
(cd "$BACKEND_DIR" && mvn spring-boot:run -q) &
BACKEND_PID=$!

echo "Waiting for backend to initialize..."

# Wait for backend health check (30 attempts, 1 second each)
BACKEND_READY=0
for i in {1..30}; do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/api/debug/health" 2>/dev/null | grep -q "200"; then
        BACKEND_READY=1
        echo "✓ Backend is ready"
        break
    else
        printf "."
        sleep 1
    fi
done

# Try dev mode if production failed
if [ $BACKEND_READY -eq 0 ]; then
    echo ""
    echo "⚠ Production backend failed. Trying dev mode (H2 database)..."
    kill $BACKEND_PID 2>/dev/null
    wait $BACKEND_PID 2>/dev/null
    
    # Start backend in dev mode
    (cd "$BACKEND_DIR" && mvn -DskipTests -Dspring-boot.run.profiles=dev spring-boot:run -q) &
    BACKEND_PID=$!
    
    # Wait for dev backend
    for i in {1..20}; do
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/api/debug/health" 2>/dev/null | grep -q "200"; then
            BACKEND_READY=1
            echo "✓ Dev backend is ready"
            break
        else
            printf "."
            sleep 1
        fi
    done
fi

if [ $BACKEND_READY -eq 0 ]; then
    echo ""
    echo "❌ Backend failed to start. Check logs and network connection."
    exit 1
fi

echo
echo "[2/2] Starting Frontend Application..."
echo "Frontend GUI will open in a new window."

# Start frontend in background
(cd "$FRONTEND_DIR" && mvn -DskipTests javafx:run) &
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
trap "echo ''; echo 'Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT
wait
wait