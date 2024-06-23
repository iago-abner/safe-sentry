<template>
  <v-container fluid class="overflow-hidden">
    <v-row class="d-flex h-100">
      <v-col cols="4" class="d-flex h-100">
        <v-card class="d-flex flex-column h-100 w-100 rounded overflow-y-scroll" title="Veículos">
          <v-card-text>
            <v-list>
              <v-list-item-group>
                <v-list-item v-for="(vehicle, idx) in vehicles" :key="idx">
                  <v-list-item-content>
                    <v-list-item-title>{{ vehicle.plate }}</v-list-item-title>
                    <v-list-item-subtitle>{{ vehicle.model }}</v-list-item-subtitle>
                  </v-list-item-content>
                </v-list-item>
              </v-list-item-group>
            </v-list>
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="8" class="d-flex flex-column h-100">
        <GoogleMap api-key="123456" class="Map" :center="center" :zoom="3">
          <Marker
            v-for="(coordinate, idx) in coordinates"
            :options="{ position: coordinate }"
            :key="idx"
          />
          <Polyline :options="Path" />
        </GoogleMap>
        <v-card title="Alertas" class="mt-4 overflow-y-scroll rounded">
          <v-list>
            <v-list-item-group>
              <v-list-item v-for="(alert, idx) in alerts" :key="idx">
                <v-list-item-content>
                  <v-list-item-title>{{ alert.message }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </v-list-item-group>
          </v-list>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import { GoogleMap, Polyline, Marker } from 'vue3-google-map'

const center = ref({ lat: 0, lng: -180 })
const coordinates = ref([
  { lat: 37.772, lng: -122.214 },
  { lat: 21.291, lng: -157.821 },
  { lat: -18.142, lng: 178.431 },
  { lat: -27.467, lng: 153.027 }
])
const Path = ref({
  path: coordinates.value,
  geodesic: true,
  strokeColor: '#FF0000',
  strokeOpacity: 1.0,
  strokeWeight: 2
})

const vehicles = ref([
  { plate: 'ABC-1234', model: 'Toyota Corolla' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },
  { plate: 'XYZ-5678', model: 'Honda Civic' },

  { plate: 'DEF-9012', model: 'Ford Focus' }
])

const alerts = ref([
  { message: 'Manutenção pendente para veículo ABC-1234.' },
  { message: 'Manutenção pendente para veículo ABC-1234.' },
  { message: 'Manutenção pendente para veículo ABC-1234.' },
  { message: 'Manutenção pendente para veículo ABC-1234.' },
  { message: 'Manutenção pendente para veículo ABC-1234.' },
  { message: 'Manutenção pendente para veículo ABC-1234.' },
  { message: 'Veículo XYZ-5678 fora da rota prevista.' }
])
</script>

<style scoped>
.Map {
  width: 100%;
  height: 100%;
  border-radius: 8px;
  background-color: #f0f0f0;
}
</style>
