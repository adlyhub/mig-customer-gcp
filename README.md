# Firebase Migration Guide
**Source:** `smodin-prod` → **Destination:** New GCP Project

---

## Prerequisites

```bash
npm install -g firebase-tools
gcloud auth login
firebase login
```

---

## Migration Order

### 1. Export & Import Auth Users

```bash
chmod +x migrate.sh migrate-auth.sh
./migrate.sh
```

Then fill in hash params and run:
```bash
./migrate-auth.sh
```

**Where to find hash params:**
> Firebase Console → Authentication → Users → ⋮ (top-right menu) → **Password hash parameters**

---

### 2. Firestore Export (via GCS bucket)

The bucket must be in the **same GCP project** as the source Firestore.

```bash
# Create bucket if needed
gsutil mb -p smodin-prod gs://smodin-prod-firestore-backup

# Export
gcloud firestore export gs://smodin-prod-firestore-backup --project=smodin-prod
```

Then copy to new project's bucket and import:
```bash
# Give new project access to the bucket
gsutil iam ch serviceAccount:NEW_PROJECT_ID@appspot.gserviceaccount.com:objectViewer \
  gs://smodin-prod-firestore-backup

# Import into new project
gcloud firestore import gs://smodin-prod-firestore-backup/EXPORT_FOLDER_NAME \
  --project=NEW_PROJECT_ID
```

---

### 3. Verify UIDs Match

```bash
cd firebase-migration
npm install firebase-admin
# Place new-project-service-account.json here
node uid-verify.js
```

---

## Password Behavior After Migration

| Sign-in Method | Password After Migration |
|---------------|--------------------------|
| Google OAuth  | ✅ Works (re-links on first sign-in) |
| Email/Password | ✅ Works (scrypt hash preserved) |
| Email Link    | ⚠️ Requires re-authentication |

---

## Common Issues

**"Permission denied" on Firestore import**
→ Add the destination project's service account as `roles/datastore.importExportAdmin`

**Google OAuth users see "account not found"**
→ Normal on first login — Firebase re-creates the link automatically

**UIDs changed after import**
→ Run `uid-verify.js` to find affected users, then update Firestore docs

---

## Checklist

- [ ] Update `SOURCE_PROJECT` and `DEST_PROJECT` in scripts
- [ ] Get hash parameters from Firebase Console
- [ ] Create GCS bucket for Firestore export
- [ ] Export Auth users
- [ ] Export Firestore
- [ ] Import Auth users into new project
- [ ] Import Firestore into new project
- [ ] Run `uid-verify.js`
- [ ] Test sign-in with both Google and email/password accounts
- [ ] Update environment variables in your app to point to new project
