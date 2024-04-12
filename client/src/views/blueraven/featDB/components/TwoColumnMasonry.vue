<template>
  <v-container class="pa-0">
    <v-row>
      <v-col class="group pt-0" cols="12" md="6" v-for="n in numberOfCols">
        <FeatDbCustomFieldGroup v-for="group in getGroupsByCol(n)" :group = group
                                :user-can-edit="userCanEdit"
                                :expanded-all="expandedAll"
                                :callback="(field) => callback(field)"
                                :hardcoded-docs="hardcodedDocs"
                                :source-id="sourceId"
                                @toggle-collapse-expand="$emit('toggle-collapse-expand', $event)"
                                class="my-2"
        ></FeatDbCustomFieldGroup>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
import FeatDbCustomFieldGroup from "@/views/blueraven/featDB/components/FeatDbCustomFieldGroup.vue";
import { getCurrentInstance, computed, ref, toRefs, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const vuetify = vueInstance.$vuetify
const snackbar = vueInstance.$snackbar

const props = defineProps({
  customFieldGroups: Array,
  userCanEdit: Boolean,
  expandedAll: CollapseExpandEnum,
  hardcodedDocs: Map,
  sourceId: Number,
  callback:Function
})
const { customFieldGroups, userCanEdit, expandedAll, hardcodedDocs, sourceId, callback } = toRefs(props)


const numberOfCols = computed(() => {
  if(vuetify.breakpoint.mdAndUp) {
    return 2
  }
  return 1
})

const getGroupsByCol = (colNumber) => {
  if (vuetify.breakpoint.mdAndUp) {
    return customFieldGroups.value.filter(cfg => cfg.columnNumber === colNumber)
        .sort((cfg1, cfg2) => {
          if (cfg1.groupOrder < cfg2.groupOrder) {
            return -1
          }
          if (cfg1.groupOrder > cfg2.groupOrder) {
            return 1
          }
          return 0
        })
  }
  //if smaller than md, we only have one column, so we just need to make sure things are in the right order
  return customFieldGroups.value.sort((cfg1, cfg2) => {
    if (cfg1.groupOrder < cfg2.groupOrder) {
      return -1
    }
    if (cfg1.groupOrder > cfg2.groupOrder) {
      return 1
    }
    if (cfg1.groupOrder === cfg2.groupOrder) {
      if(cfg1.columnNumber > cfg2.columnNumber){
        return 1
      }
      return -1
    }
  })
}
</script>

<style lang="scss" scoped>
</style>
