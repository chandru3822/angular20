<template>
<div>editor {{ reportId }}</div>
</template>

<script setup>
import useReportStore from '@/views/flow/smartlist/reportStore'
import { getCurrentInstance } from 'vue'

const vueInstance = getCurrentInstance().proxy
const route = vueInstance.$route

const reportStore = useReportStore()
reportStore.$subscribe((mut, state) => localStorage.setItem('report', JSON.stringify(state)))

const reportId = route.params.reportId
</script>

<style scoped>

</style>