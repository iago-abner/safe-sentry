<script setup lang="ts">
import { RouterLink } from 'vue-router'
</script>

<template>
  <nav>
    <RouterLink to="/">Início</RouterLink>
    <RouterLink to="/vehicles">Veículos</RouterLink>
    <RouterLink to="/alerts">Alertas</RouterLink>
    <RouterLink to="/reports">Relatórios</RouterLink>
    <RouterLink to="/drivers">Motoristas</RouterLink>
  </nav>
</template>

<style scoped>
nav {
  width: 100%;
  font-size: 16px;
  text-align: center;
}

nav a.router-link-exact-active {
  color: hsla(160, 100%, 37%, 1);
}

nav a.router-link-exact-active:hover {
  background-color: transparent;
}

nav a {
  display: inline-block;
  padding: 0 3rem;
  border-left: 1px solid var(--color-border);
}

nav a:first-of-type {
  border: 0;
}
</style>
