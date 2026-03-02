#!/bin/bash
# ============================================================
# Step 2: Import Firebase Auth Users into NEW project
# Run AFTER getting hash parameters from Firebase Console
# ============================================================

DEST_PROJECT="YOUR_NEW_PROJECT_ID"   # <-- change this

# -----------------------------------------------------------
# 🔑 Fill these in from Firebase Console:
#    Authentication → Users → ⋮ → Password hash parameters
# -----------------------------------------------------------
HASH_KEY="YOUR_BASE64_HASH_KEY"          # base64_signer_key
SALT_SEPARATOR="YOUR_SALT_SEPARATOR"     # base64_salt_separator
ROUNDS="8"                               # rounds
MEM_COST="14"                            # mem_cost

echo "Importing Auth users into $DEST_PROJECT..."

firebase auth:import auth-users.json \
  --hash-algo=SCRYPT \
  --hash-key=$HASH_KEY \
  --salt-separator=$SALT_SEPARATOR \
  --rounds=$ROUNDS \
  --mem-cost=$MEM_COST \
  --project=$DEST_PROJECT

echo ""
echo "✅ Auth import complete!"
echo ""
echo "⚠️  IMPORTANT: Google/OAuth users will re-link automatically"
echo "   on first sign-in. Email/password users keep their passwords."
