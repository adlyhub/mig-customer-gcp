// ============================================================
// uid-remap.js — Optional: verify UIDs match after migration
// Run this if you suspect UIDs changed during import
// npm install firebase-admin
// ============================================================

const admin = require("firebase-admin");
const fs = require("fs");

// Point to your NEW project's service account key
const serviceAccount = require("./new-project-service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function verifyUIDsExist() {
  console.log("Loading exported users...");
  const exported = JSON.parse(fs.readFileSync("auth-users.json", "utf8"));
  const users = exported.users || [];

  console.log(`Checking ${users.length} users in new project...`);

  let missing = 0;
  for (const user of users) {
    try {
      await admin.auth().getUser(user.localId);
    } catch (e) {
      console.warn(`❌ UID NOT FOUND: ${user.localId} (${user.email})`);
      missing++;
    }
  }

  if (missing === 0) {
    console.log("✅ All UIDs exist in new project — Firestore refs are safe!");
  } else {
    console.log(`\n⚠️  ${missing} UIDs missing. Firestore documents referencing`);
    console.log("   these UIDs will be broken. Manual UID remapping needed.");
  }

  process.exit(0);
}

verifyUIDsExist();
