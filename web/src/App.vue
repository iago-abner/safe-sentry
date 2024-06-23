<script setup lang="ts">
import { RouterView } from 'vue-router'
import TheHeader from './components/TheHeader.vue'
</script>

<template>
  <v-app theme="dark" class="d-flex h-screen">
    <v-layout>
      <v-app-bar flat>
        <TheHeader />
      </v-app-bar>
      <v-main class="d-flex h-100">
        <RouterView />
      </v-main>
    </v-layout>
  </v-app>
</template>
