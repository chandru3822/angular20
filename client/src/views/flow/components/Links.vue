<template>
  <v-col v-if="links.length > 0" class="pt-4">
    <v-row>
      <v-col class="text-left pa-0">
        <v-toolbar dense color="transparent" class="elevation-0 mb-n2">
          <v-toolbar-title class="headline-small">Links</v-toolbar-title>
        </v-toolbar>
        <v-row v-for="(l, index) in links" class="px-7 py-1">
          <a  :key="l.id" text target="_blank" @click="followThisLink(l.url)" class="text-capitalize body-medium"><v-icon color="primary" class="pr-1">mdi-link</v-icon>{{l.link}}</a>
        </v-row>
      </v-col>
    </v-row>
  </v-col>
</template>

<script setup>
import {getRequest, followLink} from '@/helpers/helpers'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

// @TODO: need to generisize this so it can be used for any object type (project, process step, contact, user, org)

const links = ref([])
const linkPath = ref('')

const props = defineProps({
  projectId: Number,
  processStepId: Number,
  projectProcessStepId: Number,
  ppseId: Number,
  contactId: Number
})
const { projectId, processStepId, projectProcessStepId, ppseId, contactId } = toRefs(props)

onMounted(() => {
  //leaving like this cuz i think they will add project links down the road
  linkPath.value = `/links/processStep/${processStepId.value}`
  fetchLinks()
})


const fetchLinks = async () => {
  const {data} = await getRequest(linkPath.value)
  links.value = data
}
const followThisLink = (url) => {
  let params = {
    projectId: projectId.value,
    ppsId: projectProcessStepId.value,
    contactId: contactId.value,
    ppseId: ppseId.value
  }

  followLink(vueInstance, url, params)
}
</script>
