<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <v-data-table
      :items="tableData"
      :headers="tableHeaders"
      :footer-props="footerProps"
      :hide-default-footer="true"
    >

      <template #no-data>
        <span class="default-text-color">No available data</span>
      </template>


      <div>
        a
      </div>
    </v-data-table>

  </v-container>
</template>

<script setup>
  import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
  import { useUserStore } from "@/stores/UserStore.js";
  import {useRoute, useRouter} from "vue-router/composables";
  import { useAppStore } from '@/stores/AppStore.js'
  import constants from "@/helpers/constants.js";

  const appStore = useAppStore()
  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

  const props = defineProps({
    title: String,
    tableData: Array,
    tableHeaders: Array
  })
  const { title, filterList, filterTypes, tableData, tableHeaders } = toRefs(props)

  const footerProps = ref({
    'items-per-page-options': [25, 50, 100, 500, 1000],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })
</script>

<style lang="scss" scoped>

</style>
