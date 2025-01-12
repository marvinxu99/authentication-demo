<script setup lang="ts">
import * as clientWithState from '../auth'
const res = clientWithState.tokenIntrospection()
</script>

<template>
  Token Introspection:
  <pre>
{{ JSON.stringify(res, null, 2) }}
  </pre>
</template>
