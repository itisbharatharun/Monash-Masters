import { useState } from 'react';

import {
  confirmPasswordReset,
  confirmUserEmail,
  loginUser,
  registerUser,
  requestPasswordReset,
  resendConfirmationCode,
} from '../services/authService';

const getErrorMessage = (error) => {
  if (!error) {
    return 'Something went wrong. Please try again.';
  }

  return error.message || error.name || 'Something went wrong. Please try again.';
};

const panelStyle = {
  background: 'rgba(255, 255, 255, 0.94)',
  border: '1px solid rgba(216, 226, 220, 0.95)',
  borderRadius: '32px',
  boxShadow: '0 28px 80px rgba(8, 28, 21, 0.12)',
};

const inputStyle = {
  width: '100%',
  border: '1px solid #d7e4dc',
  borderRadius: '16px',
  padding: '14px 16px',
  fontSize: '15px',
  outline: 'none',
  background: '#ffffff',
  color: '#081c15',
};

const labelStyle = {
  display: 'block',
  marginBottom: '8px',
  color: '#1b4332',
  fontSize: '13px',
  fontWeight: 900,
  letterSpacing: '0.04em',
  textTransform: 'uppercase',
};

const primaryButtonStyle = {
  width: '100%',
  border: 'none',
  borderRadius: '18px',
  padding: '15px 18px',
  background: 'linear-gradient(135deg, #1b4332, #2d6a4f)',
  color: '#ffffff',
  fontSize: '16px',
  fontWeight: 900,
  cursor: 'pointer',
  boxShadow: '0 16px 35px rgba(27, 67, 50, 0.24)',
};

const secondaryButtonStyle = {
  border: '1px solid #b7d9c2',
  borderRadius: '14px',
  padding: '11px 14px',
  background: '#f4fbf6',
  color: '#1b4332',
  fontSize: '14px',
  fontWeight: 900,
  cursor: 'pointer',
};

const linkButtonStyle = {
  border: 'none',
  background: 'transparent',
  color: '#2d6a4f',
  fontSize: '13px',
  fontWeight: 900,
  cursor: 'pointer',
  padding: 0,
  textDecoration: 'underline',
};

function Field({ label, children }) {
  return (
    <label style={{ display: 'block', marginBottom: '16px' }}>
      <span style={labelStyle}>{label}</span>
      {children}
    </label>
  );
}

function AuthPage({ onLoginSuccess }) {
  const [mode, setMode] = useState('login');
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    code: '',
    newPassword: '',
  });

  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const updateForm = (field, value) => {
    setForm((currentForm) => ({
      ...currentForm,
      [field]: value,
    }));
  };

  const resetMessages = () => {
    setMessage('');
    setError('');
  };

  const switchMode = (nextMode) => {
    setMode(nextMode);
    resetMessages();
  };

  const handleLogin = async (event) => {
    event.preventDefault();
    resetMessages();
    setLoading(true);

    try {
      await loginUser({
        email: form.email.trim(),
        password: form.password,
      });

      setMessage('Login successful. Loading dashboard...');
      await onLoginSuccess?.();
    } catch (loginError) {
      if (loginError?.name === 'UserNotConfirmedException') {
        setMode('confirm');
        setMessage('Please verify your email before signing in.');
      } else {
        setError(getErrorMessage(loginError));
      }
    } finally {
      setLoading(false);
    }
  };

  const handleSignup = async (event) => {
    event.preventDefault();
    resetMessages();
    setLoading(true);

    const email = form.email.trim();

    try {
      await registerUser({
        email,
        password: form.password,
        firstName: form.firstName.trim(),
        lastName: form.lastName.trim(),
      });

      setMode('confirm');
      setMessage(
        'Account created. Please check your email for the verification code.'
      );
    } catch (signupError) {
      const errorMessage = getErrorMessage(signupError);

      if (
        signupError?.name === 'UsernameExistsException' ||
        errorMessage.toLowerCase().includes('user already exists') ||
        errorMessage.toLowerCase().includes('already exists')
      ) {
        try {
          await resendConfirmationCode(email);

          setMode('confirm');
          setMessage(
            'This account already exists but may not be verified. A new verification code has been sent to your email.'
          );
        } catch (resendError) {
          const resendMessage = getErrorMessage(resendError);

          if (
            resendMessage.toLowerCase().includes('already confirmed') ||
            resendMessage.toLowerCase().includes('confirmed')
          ) {
            setMode('login');
            setError('This account already exists and is verified. Please sign in.');
          } else {
            setMode('confirm');
            setError(
              'This account already exists. If it is not verified, use Resend verification code on this page.'
            );
          }
        }

        return;
      }

      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleConfirmEmail = async (event) => {
    event.preventDefault();
    resetMessages();
    setLoading(true);

    try {
      await confirmUserEmail({
        email: form.email.trim(),
        code: form.code.trim(),
      });

      setMode('login');
      setForm((currentForm) => ({
        ...currentForm,
        code: '',
      }));
      setMessage('Email verified successfully. You can now sign in.');
    } catch (confirmError) {
      setError(getErrorMessage(confirmError));
    } finally {
      setLoading(false);
    }
  };

  const handleResendCode = async () => {
    resetMessages();

    if (!form.email.trim()) {
      setError('Enter your email address first.');
      return;
    }

    setLoading(true);

    try {
      await resendConfirmationCode(form.email.trim());
      setMessage('A new verification code has been sent to your email.');
    } catch (resendError) {
      setError(getErrorMessage(resendError));
    } finally {
      setLoading(false);
    }
  };

  const handleForgotPassword = async (event) => {
    event.preventDefault();
    resetMessages();

    const email = form.email.trim();

    if (!email) {
      setError('Please enter your email address.');
      return;
    }

    setLoading(true);

    try {
      await requestPasswordReset(email);

      setMode('resetPassword');
      setMessage('A password reset code has been sent to your email.');
    } catch (resetError) {
      const resetMessage = getErrorMessage(resetError);

      if (
        resetError?.name === 'UserNotConfirmedException' ||
        resetMessage.toLowerCase().includes('not confirmed')
      ) {
        setMode('confirm');
        setMessage('Please verify your email before resetting your password.');
      } else {
        setError(resetMessage);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleConfirmPasswordReset = async (event) => {
    event.preventDefault();
    resetMessages();

    const email = form.email.trim();
    const code = form.code.trim();
    const newPassword = form.newPassword;

    if (!email || !code || !newPassword) {
      setError('Please enter your email, reset code, and new password.');
      return;
    }

    setLoading(true);

    try {
      await confirmPasswordReset({
        email,
        code,
        newPassword,
      });

      setMode('login');
      setForm((currentForm) => ({
        ...currentForm,
        password: '',
        code: '',
        newPassword: '',
      }));
      setMessage('Password reset successful. You can now sign in.');
    } catch (confirmResetError) {
      setError(getErrorMessage(confirmResetError));
    } finally {
      setLoading(false);
    }
  };

  const isLoginMode = mode === 'login';
  const isSignupMode = mode === 'signup';
  const isConfirmMode = mode === 'confirm';
  const isForgotMode = mode === 'forgotPassword';
  const isResetPasswordMode = mode === 'resetPassword';

  return (
    <main
      style={{
        minHeight: '100vh',
        background:
          'radial-gradient(circle at top left, #b7e4c7 0, transparent 34%), radial-gradient(circle at bottom right, #d8f3dc 0, transparent 30%), linear-gradient(135deg, #f7fbf8 0%, #eef7f0 52%, #f4f8f5 100%)',
        color: '#081c15',
        fontFamily:
          'Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '36px',
      }}
    >
      <section
        style={{
          width: '100%',
          maxWidth: '1180px',
          display: 'grid',
          gridTemplateColumns: 'minmax(0, 1.05fr) minmax(420px, 0.95fr)',
          gap: '28px',
          alignItems: 'stretch',
        }}
      >
        <div
          style={{
            ...panelStyle,
            padding: '42px',
            background:
              'linear-gradient(145deg, rgba(8, 28, 21, 0.96), rgba(27, 67, 50, 0.96))',
            color: '#ffffff',
            overflow: 'hidden',
            position: 'relative',
          }}
        >
          <div
            style={{
              position: 'absolute',
              width: '260px',
              height: '260px',
              borderRadius: '50%',
              background: 'rgba(183, 228, 199, 0.12)',
              right: '-90px',
              top: '-70px',
            }}
          />

          <div
            style={{
              position: 'relative',
              zIndex: 1,
              minHeight: '100%',
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <div
              style={{
                width: '62px',
                height: '62px',
                borderRadius: '22px',
                background: 'linear-gradient(135deg, #52b788, #b7e4c7)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '30px',
                marginBottom: '26px',
                boxShadow: '0 20px 45px rgba(0, 0, 0, 0.18)',
              }}
            >
              🐾
            </div>

            <p
              style={{
                margin: 0,
                color: '#95d5b2',
                fontSize: '13px',
                fontWeight: 900,
                letterSpacing: '0.1em',
                textTransform: 'uppercase',
              }}
            >
              AussieEcoLens
            </p>

            <h1
              style={{
                margin: '14px 0 18px',
                maxWidth: '640px',
                color: '#ffffff',
                fontSize: '52px',
                lineHeight: 1.02,
                letterSpacing: '-0.06em',
              }}
            >
              Secure wildlife media intelligence dashboard
            </h1>

            <p
              style={{
                margin: 0,
                maxWidth: '620px',
                color: '#d8f3dc',
                fontSize: '18px',
                lineHeight: 1.75,
              }}
            >
              Sign in to upload, classify, search, manage, and receive
              notifications for Australian wildlife media across the AWS and GCP
              serverless pipeline.
            </p>

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
                gap: '14px',
                marginTop: '34px',
              }}
            >
              {[
                ['🔐', 'Cognito protected access'],
                ['☁️', 'AWS and GCP integration'],
                ['🧠', 'ML-based species detection'],
                ['📧', 'Species alert notifications'],
              ].map(([icon, text]) => (
                <div
                  key={text}
                  style={{
                    border: '1px solid rgba(216, 243, 220, 0.16)',
                    background: 'rgba(255, 255, 255, 0.08)',
                    borderRadius: '20px',
                    padding: '18px',
                  }}
                >
                  <div style={{ fontSize: '22px', marginBottom: '10px' }}>
                    {icon}
                  </div>
                  <p
                    style={{
                      margin: 0,
                      color: '#ffffff',
                      fontSize: '14px',
                      fontWeight: 800,
                      lineHeight: 1.45,
                    }}
                  >
                    {text}
                  </p>
                </div>
              ))}
            </div>

            <div
              style={{
                marginTop: 'auto',
                paddingTop: '34px',
                color: '#95d5b2',
                fontSize: '14px',
                lineHeight: 1.6,
              }}
            >
              FIT5225 Assignment 2 · Multi-cloud wildlife observation system
            </div>
          </div>
        </div>

        <div style={{ ...panelStyle, padding: '34px' }}>
          <div style={{ marginBottom: '26px' }}>
            <p
              style={{
                margin: 0,
                color: '#2d6a4f',
                fontSize: '13px',
                fontWeight: 900,
                letterSpacing: '0.08em',
                textTransform: 'uppercase',
              }}
            >
              {isLoginMode && 'Welcome back'}
              {isSignupMode && 'Create account'}
              {isConfirmMode && 'Email verification'}
              {isForgotMode && 'Password recovery'}
              {isResetPasswordMode && 'Set new password'}
            </p>

            <h2
              style={{
                margin: '8px 0 10px',
                color: '#081c15',
                fontSize: '34px',
                lineHeight: 1.1,
                letterSpacing: '-0.04em',
              }}
            >
              {isLoginMode && 'Sign in to continue'}
              {isSignupMode && 'Register your account'}
              {isConfirmMode && 'Verify your email'}
              {isForgotMode && 'Forgot your password?'}
              {isResetPasswordMode && 'Reset your password'}
            </h2>

            <p
              style={{
                margin: 0,
                color: '#607166',
                fontSize: '15px',
                lineHeight: 1.6,
              }}
            >
              {isLoginMode &&
                'Use your Cognito account to access the protected dashboard.'}
              {isSignupMode &&
                'Create a new account. A verification code will be sent to your email.'}
              {isConfirmMode &&
                'Enter the verification code sent to your email address.'}
              {isForgotMode &&
                'Enter your email address and Cognito will send a password reset code.'}
              {isResetPasswordMode &&
                'Enter the reset code from your email and choose a new password.'}
            </p>
          </div>

          {message && (
            <div
              style={{
                marginBottom: '18px',
                padding: '14px 16px',
                borderRadius: '16px',
                background: '#e9f8ee',
                border: '1px solid #b7e4c7',
                color: '#1b4332',
                fontSize: '14px',
                fontWeight: 700,
                lineHeight: 1.5,
              }}
            >
              {message}
            </div>
          )}

          {error && (
            <div
              style={{
                marginBottom: '18px',
                padding: '14px 16px',
                borderRadius: '16px',
                background: '#fff1f2',
                border: '1px solid #fecdd3',
                color: '#9f1239',
                fontSize: '14px',
                fontWeight: 700,
                lineHeight: 1.5,
              }}
            >
              {error}
            </div>
          )}

          {isLoginMode && (
            <form onSubmit={handleLogin}>
              <Field label="Email address">
                <input
                  style={inputStyle}
                  type="email"
                  value={form.email}
                  onChange={(event) => updateForm('email', event.target.value)}
                  placeholder="name@example.com"
                  autoComplete="email"
                  required
                />
              </Field>

              <Field label="Password">
                <input
                  style={inputStyle}
                  type="password"
                  value={form.password}
                  onChange={(event) =>
                    updateForm('password', event.target.value)
                  }
                  placeholder="Enter your password"
                  autoComplete="current-password"
                  required
                />
              </Field>

              <div
                style={{
                  display: 'flex',
                  justifyContent: 'flex-end',
                  marginTop: '-6px',
                  marginBottom: '16px',
                }}
              >
                <button
                  type="button"
                  onClick={() => switchMode('forgotPassword')}
                  style={linkButtonStyle}
                >
                  Forgot password?
                </button>
              </div>

              <button
                type="submit"
                disabled={loading}
                style={{
                  ...primaryButtonStyle,
                  opacity: loading ? 0.72 : 1,
                }}
              >
                {loading ? 'Signing in...' : 'Sign in'}
              </button>
            </form>
          )}

          {isSignupMode && (
            <form onSubmit={handleSignup}>
              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
                  gap: '14px',
                }}
              >
                <Field label="First name">
                  <input
                    style={inputStyle}
                    type="text"
                    value={form.firstName}
                    onChange={(event) =>
                      updateForm('firstName', event.target.value)
                    }
                    placeholder="First name"
                    autoComplete="given-name"
                    required
                  />
                </Field>

                <Field label="Last name">
                  <input
                    style={inputStyle}
                    type="text"
                    value={form.lastName}
                    onChange={(event) =>
                      updateForm('lastName', event.target.value)
                    }
                    placeholder="Last name"
                    autoComplete="family-name"
                    required
                  />
                </Field>
              </div>

              <Field label="Email address">
                <input
                  style={inputStyle}
                  type="email"
                  value={form.email}
                  onChange={(event) => updateForm('email', event.target.value)}
                  placeholder="name@example.com"
                  autoComplete="email"
                  required
                />
              </Field>

              <Field label="Password">
                <input
                  style={inputStyle}
                  type="password"
                  value={form.password}
                  onChange={(event) =>
                    updateForm('password', event.target.value)
                  }
                  placeholder="Minimum 8 characters"
                  autoComplete="new-password"
                  required
                />
              </Field>

              <button
                type="submit"
                disabled={loading}
                style={{
                  ...primaryButtonStyle,
                  opacity: loading ? 0.72 : 1,
                }}
              >
                {loading ? 'Creating account...' : 'Create account'}
              </button>
            </form>
          )}

          {isConfirmMode && (
            <form onSubmit={handleConfirmEmail}>
              <Field label="Email address">
                <input
                  style={inputStyle}
                  type="email"
                  value={form.email}
                  onChange={(event) => updateForm('email', event.target.value)}
                  placeholder="name@example.com"
                  autoComplete="email"
                  required
                />
              </Field>

              <Field label="Verification code">
                <input
                  style={{
                    ...inputStyle,
                    letterSpacing: '0.16em',
                    fontWeight: 800,
                  }}
                  type="text"
                  value={form.code}
                  onChange={(event) => updateForm('code', event.target.value)}
                  placeholder="Enter code"
                  autoComplete="one-time-code"
                  required
                />
              </Field>

              <button
                type="submit"
                disabled={loading}
                style={{
                  ...primaryButtonStyle,
                  opacity: loading ? 0.72 : 1,
                }}
              >
                {loading ? 'Verifying...' : 'Verify email'}
              </button>

              <button
                type="button"
                disabled={loading}
                onClick={handleResendCode}
                style={{
                  ...secondaryButtonStyle,
                  width: '100%',
                  marginTop: '12px',
                  opacity: loading ? 0.72 : 1,
                }}
              >
                Resend verification code
              </button>
            </form>
          )}

          {isForgotMode && (
            <form onSubmit={handleForgotPassword}>
              <Field label="Email address">
                <input
                  style={inputStyle}
                  type="email"
                  value={form.email}
                  onChange={(event) => updateForm('email', event.target.value)}
                  placeholder="name@example.com"
                  autoComplete="email"
                  required
                />
              </Field>

              <button
                type="submit"
                disabled={loading}
                style={{
                  ...primaryButtonStyle,
                  opacity: loading ? 0.72 : 1,
                }}
              >
                {loading ? 'Sending reset code...' : 'Send reset code'}
              </button>
            </form>
          )}

          {isResetPasswordMode && (
            <form onSubmit={handleConfirmPasswordReset}>
              <Field label="Email address">
                <input
                  style={inputStyle}
                  type="email"
                  value={form.email}
                  onChange={(event) => updateForm('email', event.target.value)}
                  placeholder="name@example.com"
                  autoComplete="email"
                  required
                />
              </Field>

              <Field label="Reset code">
                <input
                  style={{
                    ...inputStyle,
                    letterSpacing: '0.16em',
                    fontWeight: 800,
                  }}
                  type="text"
                  value={form.code}
                  onChange={(event) => updateForm('code', event.target.value)}
                  placeholder="Enter reset code"
                  autoComplete="one-time-code"
                  required
                />
              </Field>

              <Field label="New password">
                <input
                  style={inputStyle}
                  type="password"
                  value={form.newPassword}
                  onChange={(event) =>
                    updateForm('newPassword', event.target.value)
                  }
                  placeholder="Enter new password"
                  autoComplete="new-password"
                  required
                />
              </Field>

              <button
                type="submit"
                disabled={loading}
                style={{
                  ...primaryButtonStyle,
                  opacity: loading ? 0.72 : 1,
                }}
              >
                {loading ? 'Resetting password...' : 'Reset password'}
              </button>

              <button
                type="button"
                disabled={loading}
                onClick={handleForgotPassword}
                style={{
                  ...secondaryButtonStyle,
                  width: '100%',
                  marginTop: '12px',
                  opacity: loading ? 0.72 : 1,
                }}
              >
                Resend reset code
              </button>
            </form>
          )}

          <div
            style={{
              display: 'flex',
              gap: '10px',
              flexWrap: 'wrap',
              justifyContent: 'center',
              marginTop: '24px',
              paddingTop: '22px',
              borderTop: '1px solid #e4ece7',
            }}
          >
            {isLoginMode && (
              <button
                type="button"
                onClick={() => switchMode('signup')}
                style={secondaryButtonStyle}
              >
                Create new account
              </button>
            )}

            {isSignupMode && (
              <button
                type="button"
                onClick={() => switchMode('login')}
                style={secondaryButtonStyle}
              >
                Back to sign in
              </button>
            )}

            {isConfirmMode && (
              <>
                <button
                  type="button"
                  onClick={() => switchMode('login')}
                  style={secondaryButtonStyle}
                >
                  Back to sign in
                </button>

                <button
                  type="button"
                  onClick={() => switchMode('signup')}
                  style={secondaryButtonStyle}
                >
                  Create new account
                </button>
              </>
            )}

            {(isForgotMode || isResetPasswordMode) && (
              <>
                <button
                  type="button"
                  onClick={() => switchMode('login')}
                  style={secondaryButtonStyle}
                >
                  Back to sign in
                </button>

                <button
                  type="button"
                  onClick={() => switchMode('signup')}
                  style={secondaryButtonStyle}
                >
                  Create new account
                </button>
              </>
            )}
          </div>
        </div>
      </section>
    </main>
  );
}

export default AuthPage;