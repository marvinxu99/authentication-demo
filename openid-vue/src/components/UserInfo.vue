<script setup lang="ts">
import * as clientWithState from '../auth'
const res = clientWithState.sessionState() ? await clientWithState.fetchUserInfo() : null
console.log(res)
</script>

<template>
  <div v-if="res">
  User Info:
<pre>
{{ JSON.stringify(res, null, 2) }}
</pre>
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
    <a :href="'http://localhost:8080/realms/test/account?referrer=openid-vue&referrer_uri=' + encodeURIComponent('http://localhost:5173/#test')">Account console</a>
  </div>

</template>
