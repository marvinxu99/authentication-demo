<script setup lang="ts">
import * as clientWithState from '../auth'
import * as jose from 'jose'
const res = clientWithState.sessionState() ? await clientWithState.fetchUserInfo() : null
const idToken = clientWithState.idToken()
function accountConsole() {
  return 'http://localhost:8080/realms/test/account?referrer=openid-vue&referrer_uri=' + encodeURIComponent(window.location.href)
}
</script>

<template>
  <div v-if="res">
  User Info:
<pre>
{{ JSON.stringify(res, null, 2) }}
</pre>
<div v-if="idToken">
    ID Token:
<pre>
{{ jose.decodeJwt(idToken) }}
</pre>
</div>

  <br>
  <a @click="clientWithState.logout()">log out now</a>
    or <a @click="clientWithState.loginWithPrompt('login', undefined)">re-authenticate</a>
  </div>

  <div v-if="res == null">
  Not logged int - <a @click="clientWithState.loginWithPrompt('login')">log in now</a>
    <span v-if="clientWithState.isRegistrationSupported()">
    or <a @click="clientWithState.loginWithPrompt('create')">register</a>
    </span>
  </div>

  <div v-if="res && !res.email_verified">
    <!-- Not implemented yet: VERIFY_EMAIL
     https://github.com/keycloak/keycloak/issues/25154 -->
    <!--
    <a @click="clientWithState.loginWithPrompt(undefined, 'VERIFY_EMAIL')">Verify Email</a> -->
  </div>

  <div v-if="res">
    <!-- works: UPDATE_PASSWORD, delete_account (if enabled and user has the permissions), UPDATE_EMAIL (if enabled), UPDATE_PROFILE -->
    <a @click="clientWithState.loginWithPrompt(undefined, 'UPDATE_PROFILE')">Update profile</a> or
    <a @click="clientWithState.loginWithPrompt(undefined, 'UPDATE_PASSWORD')">Update password</a> or
    <a @click="clientWithState.loginWithPrompt(undefined, undefined, 'address')">Extra scope address</a> or
    <a @click="clientWithState.loginWithPrompt(undefined, undefined, 'acr', '2')">ACR 2</a> or
    <!-- adding street and country for address plus others -->
    <a :href="accountConsole()" >Account console</a>
  </div>

</template>
