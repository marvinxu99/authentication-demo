<script setup lang="ts">
import { ref, onMounted } from 'vue'
import * as clientWithState from '../auth'
import * as jose from 'jose'
import type { UserInfoResponse } from "oauth4webapi"

const res = ref<UserInfoResponse | null>(null)
const idToken = ref<string | undefined>(undefined)

//const res = clientWithState.sessionState() ? await clientWithState.fetchUserInfo() : null
//const idToken = clientWithState.idToken()
onMounted(async () => {
  if (clientWithState.sessionState()) {
    res.value = await clientWithState.fetchUserInfo()
    idToken.value = clientWithState.idToken()
  }
})

function accountConsole() {
  return 'http://localhost:8080/realms/MyRealm/account?referrer=openid-vue&referrer_uri=' + encodeURIComponent(window.location.href)
}
</script>

<template>
  <div v-if="res">
    <details>
      <summary>User Info</summary>
      <pre>
      {{ JSON.stringify(res, null, 2) }}
      </pre>
    </details>
    <div v-if="idToken">
      <details>
        <summary>ID Token</summary>
        <pre>
        {{ jose.decodeJwt(idToken) }}
        </pre>
      </details>
    </div>

    <br>
    <a @click="clientWithState.logout()">log out</a>
      or <a @click="clientWithState.loginWithPrompt({prompt: 'login'})">re-authenticate</a>
  </div>

  <div v-if="res == null">
    Not logged in - <a @click="clientWithState.loginWithPrompt({ prompt: 'login'})">log in</a> or <a @click="clientWithState.loginWithPrompt({ prompt: 'login', par: true })">log in with PAR</a>
    <span v-if="clientWithState.isRegistrationSupported()">
    or <a @click="clientWithState.loginWithPrompt({ prompt: 'create'})">register</a>
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
    <a @click="clientWithState.loginWithPrompt({ kcAction: 'UPDATE_PROFILE'})">Update profile</a> or
    <a @click="clientWithState.loginWithPrompt({ kcAction: 'UPDATE_PASSWORD'})">Update password</a> or
    <a @click="clientWithState.loginWithPrompt({ extraScope: 'address'})">Extra scope address</a> or
    <a @click="clientWithState.loginWithPrompt( { extraScope: 'acr', acr: '2'})">ACR 2</a> or
    <!-- adding street and country for address plus others -->
    <a :href="accountConsole()" >Account console</a>
  </div>

</template>
