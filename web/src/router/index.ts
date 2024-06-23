import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import AlertView from '@/views/AlertView.vue'
import DriverView from '@/views/DriverView.vue'
import ReportView from '../views/ReportView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/vehicles',
      name: 'vehicles',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/VehicleView.vue')
    },
    {
      path: '/alerts',
      name: 'alerts',
      component: AlertView
    },
    {
      path: '/reports',
      name: 'report',
      component: ReportView
    },
    {
      path: '/drivers',
      name: 'driver',
      component: DriverView
    }
  ]
})

export default router
