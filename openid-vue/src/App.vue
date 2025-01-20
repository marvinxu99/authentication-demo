<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
import * as clientWithState from './auth'

const sessionState = clientWithState.sessionState()
const iframeUrl = clientWithState.checkSessionIframe();
const clientId = clientWithState.clientId();

let stat = "unchanged";
let mes = clientId + " " + sessionState;

function onIframeLoad() {
  let targetOrigin = 'http://localhost:8080'; // Validates origin
  let opFrameId: string = "session";
  let timerID: number;

  function check_session() {
    let win: WindowProxy = window.parent.frames[opFrameId].contentWindow
    win.postMessage(mes, 'http://localhost:8080');
  }

  function setTimer() {
    check_session();
    timerID = setInterval(check_session, 1000);
  }

  window.addEventListener("message", receiveMessage, false);

  function receiveMessage(e: MessageEvent) {
    if (e.origin !== targetOrigin) {
      return;
    }

    stat = e.data;

    if (stat === "changed") {
      clearInterval(timerID);
      clientWithState.loginWithPrompt("none")
    }
  }

  setTimer()
  console.log("iframe initialized")
}

</script>

<template>
  <header>
    <div class="wrapper">

      <nav>
        <RouterLink to="/">UserInfo</RouterLink>
        <!-- doesn't work with a public client, missing the authentication
        <RouterLink to="/tokenIntrospection">TokenIntrospection</RouterLink>
         -->
        <RouterLink to="/serverInfo">ServerInfo</RouterLink>
        <!--
        <RouterLink to="/protectedResource">ProtectedResource</RouterLink>
        -->
      </nav>
    </div>
  </header>

  <iframe v-if="sessionState" :src=iframeUrl height="0" width="0" id="session" sandbox="allow-storage-access-by-user-activation allow-scripts allow-same-origin"
  @load="onIframeLoad">
  </iframe>

  <RouterView />
</template>

<style scoped>
header {
  line-height: 1.5;
  max-height: 100vh;
}

nav {
  width: 100%;
  font-size: 12px;
  text-align: center;
  margin-top: 2rem;
}

nav a.router-link-exact-active {
  color: var(--color-text);
}

nav a.router-link-exact-active:hover {
  background-color: transparent;
}

nav a {
  display: inline-block;
  padding: 0 1rem;
  border-left: 1px solid var(--color-border);
}

nav a:first-of-type {
  border: 0;
}

@media (min-width: 1024px) {
  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  header .wrapper {
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }

  nav {
    text-align: left;
    margin-left: -1rem;
    font-size: 1rem;

    padding: 1rem 0;
    margin-top: 1rem;
  }
}
</style>
