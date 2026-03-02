#!/bin/bash
# ============================================================
# Firebase Auth + Firestore Migration Script
# Source Project  →  Destination Project
# ============================================================

SOURCE_PROJECT="smodin-prod"
DEST_PROJECT="YOUR_NEW_PROJECT_ID"   # <-- change this

echo "========================================="
echo " Firebase Migration: $SOURCE_PROJECT → $DEST_PROJECT"
echo "========================================="

# ----------------------------------------------------------
# STEP 1: Export Firebase Auth users
# ----------------------------------------------------------
echo ""
echo "[1/4] Exporting Auth users from $SOURCE_PROJECT..."
firebase auth:export auth-users.json \
  --format=json \
  --project=$SOURCE_PROJECT

echo "✅ Auth export done → auth-users.json"

# ----------------------------------------------------------
# STEP 2: Get password hash parameters (manual step)
# ----------------------------------------------------------
echo ""
echo "[2/4] ⚠️  MANUAL STEP REQUIRED"
echo "  Go to Firebase Console → $SOURCE_PROJECT"
echo "  Authentication → Users → ⋮ (top right) → Password hash parameters"
echo "  Copy the values and update HASH_KEY and SALT_SEPARATOR below in migrate-auth.sh"
echo ""
read -p "Press ENTER once you have the hash parameters ready..."

# ----------------------------------------------------------
# STEP 3: Export Firestore data
# ----------------------------------------------------------
echo ""
echo "[3/4] Exporting Firestore from $SOURCE_PROJECT..."
echo "  This exports to a GCS bucket — make sure it exists first."
echo ""
read -p "  Enter your GCS bucket name (e.g. gs://smodin-prod-backup): " GCS_BUCKET

gcloud firestore export $GCS_BUCKET \
  --project=$SOURCE_PROJECT

echo "✅ Firestore export done → $GCS_BUCKET"

# ----------------------------------------------------------
# STEP 4: Import Firestore into destination project
# ----------------------------------------------------------
echo ""
echo "[4/4] Importing Firestore into $DEST_PROJECT..."
read -p "  Enter the full export path from above (e.g. gs://smodin-prod-backup/2026-03-02T00:00:00_12345): " EXPORT_PATH

gcloud firestore import $EXPORT_PATH \
  --project=$DEST_PROJECT

echo "✅ Firestore import done!"
echo ""
echo "Next: run migrate-auth.sh to import Auth users"
