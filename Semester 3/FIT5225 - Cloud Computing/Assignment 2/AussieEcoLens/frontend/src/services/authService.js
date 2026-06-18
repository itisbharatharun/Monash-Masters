import {
  signUp,
  confirmSignUp,
  resendSignUpCode,
  signIn,
  signOut,
  getCurrentUser,
  fetchAuthSession,
  resetPassword,
  confirmResetPassword,
} from 'aws-amplify/auth';

export async function registerUser({ email, password, firstName, lastName }) {
  return signUp({
    username: email,
    password,
    options: {
      userAttributes: {
        email,
        given_name: firstName,
        family_name: lastName,
      },
    },
  });
}

export async function confirmUserEmail({ email, code }) {
  return confirmSignUp({
    username: email,
    confirmationCode: code,
  });
}

export async function resendConfirmationCode(email) {
  return resendSignUpCode({
    username: email,
  });
}

export async function loginUser({ email, password }) {
  return signIn({
    username: email,
    password,
  });
}

export async function requestPasswordReset(email) {
  return resetPassword({
    username: email,
  });
}

export async function confirmPasswordReset({ email, code, newPassword }) {
  return confirmResetPassword({
    username: email,
    confirmationCode: code,
    newPassword,
  });
}

export async function logoutUser() {
  return signOut();
}

export async function getLoggedInUser() {
  return getCurrentUser();
}

export async function getIdToken() {
  const session = await fetchAuthSession();

  if (!session.tokens?.idToken) {
    throw new Error('No ID token found. Please sign in again.');
  }

  return session.tokens.idToken.toString();
}