<script setup lang="ts">

import TokenIntrospection from "@/components/TokenIntrospection.vue";

</script>

<template>
  <main>
    <Suspense>
      <TokenIntrospection />
      <template #fallback>
        Loading...
      </template>
    </Suspense>
  </main>
</template>
