class EmailTemplates {
  // Security verification email template
  static String securityVerificationEmail({
    required String userName,
    required String deviceInfo,
    required String verificationUrlYes,
    required String verificationUrlNo,
    required String verificationId,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Verification - Login Attempt</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            border-bottom: 1px solid #eee;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .header h1 {
            color: #6366F1;
            margin: 0;
        }
        .content {
            margin-bottom: 30px;
        }
        .buttons {
            text-align: center;
            margin: 30px 0;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            margin: 10px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: bold;
            font-size: 16px;
        }
        .btn-yes {
            background-color: #10B981;
            color: white;
        }
        .btn-no {
            background-color: #EF4444;
            color: white;
        }
        .footer {
            text-align: center;
            font-size: 12px;
            color: #666;
            border-top: 1px solid #eee;
            padding-top: 20px;
            margin-top: 20px;
        }
        .warning {
            background-color: #FEF3C7;
            border-left: 4px solid #F59E0B;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>SecureAuth</h1>
            <p>Security Verification Required</p>
        </div>
        
        <div class="content">
            <p>Hello ${userName},</p>
            
            <p>Someone tried to log in to your account from a new device.</p>
            
            <div class="warning">
                <strong>Device Information:</strong><br>
                $deviceInfo
            </div>
            
            <p><strong>Is this you?</strong></p>
            <p>If you initiated this login, please confirm by clicking the button below. If you don't recognize this activity, your account may be compromised.</p>
        </div>
        
        <div class="buttons">
            <a href="$verificationUrlYes" class="btn btn-yes">Yes, That's Me</a>
            <a href="$verificationUrlNo" class="btn btn-no">No, It's Not Me</a>
        </div>
        
        <div class="content">
            <p>If the buttons above don't work, you can also verify using this verification ID:</p>
            <p><strong>$verificationId</strong></p>
        </div>
        
        <div class="footer">
            <p>This security verification was sent because of a login attempt from an unrecognized device.</p>
            <p>If you didn't initiate this login, please change your password immediately and contact support.</p>
            <p>© 2025 SecureAuth. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
''';
  }

  // Plain text version for email clients that don't support HTML
  static String securityVerificationEmailText({
    required String userName,
    required String deviceInfo,
    required String verificationUrlYes,
    required String verificationUrlNo,
    required String verificationId,
  }) {
    return '''
Security Verification - Login Attempt

Hello $userName,

Someone tried to log in to your account from a new device.

Device Information:
$deviceInfo

Is this you?

If you initiated this login, please confirm by visiting:
Yes: $verificationUrlYes

If you don't recognize this activity:
No: $verificationUrlNo

If the links above don't work, you can also verify using this verification ID:
$verificationId

This security verification was sent because of a login attempt from an unrecognized device.

If you didn't initiate this login, please change your password immediately and contact support.

© 2025 SecureAuth. All rights reserved.
''';
  }
}
