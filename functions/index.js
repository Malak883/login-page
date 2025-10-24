const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

// Support both env vars and Firebase runtime config
const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY || (functions.config().sendgrid && functions.config().sendgrid.key) || '';
const MAIL_FROM = process.env.MAIL_FROM || (functions.config().mail && functions.config().mail.from) || 'no-reply@example.com';
const VERIFY_BASE_URL = process.env.VERIFY_BASE_URL || (functions.config().verify && functions.config().verify.base_url) || 'https://example.com';

sgMail.setApiKey(SENDGRID_API_KEY);

exports.sendVerificationEmail = functions.https.onCall(async (data, context) => {
  const { verificationId, email } = data || {};
  if (!verificationId || !email) {
    throw new functions.https.HttpsError('invalid-argument', 'verificationId and email are required');
  }

  // VERIFY_BASE_URL should be the full URL of handleVerificationDecision function or a hosting path rewriting to it
  const actionApproveUrl = `${VERIFY_BASE_URL}?action=approve&id=${verificationId}`;
  const actionDenyUrl = `${VERIFY_BASE_URL}?action=deny&id=${verificationId}`;

  const msg = {
    to: email,
    from: MAIL_FROM,
    subject: 'Confirm your login to Flutter Login App',
    html: `
      <p>A new login attempt was detected on your account.</p>
      <p>Was this you?</p>
      <p>
        <a href="${actionApproveUrl}">Yes, that’s me</a>
        &nbsp;|&nbsp;
        <a href="${actionDenyUrl}">No, it isn’t me</a>
      </p>
    `,
  };

  try {
    if (!SENDGRID_API_KEY) {
      console.warn('SendGrid API Key not set; skipping email send.');
      return { status: 'skipped' };
    }
    await sgMail.send(msg);
    return { status: 'sent' };
  } catch (e) {
    console.error('sendVerificationEmail error', e);
    throw new functions.https.HttpsError('internal', 'Failed to send email');
  }
});

// HTTP endpoint to process decision links
exports.handleVerificationDecision = functions.https.onRequest(async (req, res) => {
  const action = (req.query.action || '').toString();
  const id = (req.query.id || '').toString();

  if (!id || (action !== 'approve' && action !== 'deny')) {
    res.status(400).send('Invalid request');
    return;
  }

  try {
    const docRef = admin.firestore().collection('verifications').doc(id);
    await docRef.set({ status: action === 'approve' ? 'approved' : 'denied', decidedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

    res.status(200).send('Thank you. You can close this page.');
  } catch (e) {
    console.error('handleVerificationDecision error', e);
    res.status(500).send('Internal error');
  }
});
