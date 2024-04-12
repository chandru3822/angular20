<template>
  <v-container v-if="tournamentLoaded"
               :style="{'background-image': null != tournament.backgroundAttachmentPresignedUrl
                  ? `url(${tournament.backgroundAttachmentPresignedUrl})` : ''}"
               class="home-page home-background">

    <v-toolbar flat class="app-toolbar" height="56px">
      {{  tournament.tournamentName }}
      <v-spacer></v-spacer>
      <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
        <v-tabs>
          <!--   todo: turn this into v-tabs in extension if constants.IS_MOBILE           -->
          <v-tab :to="`/tournament/${tournamentId}/qualifying`">
            {{ getPoolName(1) || 'Qualifying' }}
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/bracket`">
            Bracket
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/lastChance`">
            {{ getPoolName(2) || 'Last Chance'}}
          </v-tab>
          <v-tab :to="`/tournament/${tournamentId}/winners`">
            {{ getPoolName(3) || 'Winners'}}
          </v-tab>
        </v-tabs>
      </v-toolbar-items>
    </v-toolbar>
    <router-view/>


  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import moment from 'moment'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const tournament = ref({})
const tournamentLoaded = ref(false)

const tournamentId = computed(() => {
  return route.params.id
})

watch(tournamentId, async() => {
  // reset the selected group when the object type changes
  tournament.value = {}
  await getTournament()
  goToRoute()
})

onMounted(async() => {
  await getTournament()
  goToRoute()
})


const goToRoute = () => {
  //
  if(route.name === 'tournament') {
    //go to the tab that is currently in progress
    let qualifyingPool = tournament.value?.pools?.find(p => p.tournamentPoolTypeId === 1)
    let winnersPool = tournament.value?.pools?.find(p => p.tournamentPoolTypeId === 3)
    if( moment().isBetween(moment(qualifyingPool?.startDate), moment(qualifyingPool?.endDate))) {
      router.push(`/tournament/${tournamentId.value}/qualifying`)
    } else if( moment().isAfter(moment(winnersPool?.startDate))) {
      router.push(`/tournament/${tournamentId.value}/winners`)
      // router.push({name: 'tournamentWinners', params: { id: tournament.value.id }})
    } else {
      router.push(`/tournament/${tournamentId.value}/bracket`)
      // router.push({name: 'tournamentBracket', params: { id: tournament.value.id }})
    }
  }
}
const getPoolName = (typeId) => {
  return tournament.value?.pools?.find(p => p.tournamentPoolTypeId === typeId)?.customName
}
const getTournament = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}`, 'blueraven')
    tournament.value = data
    document.title = tournament.value.tournamentName || 'Albatross'
    tournamentLoaded.value = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Tournament')

    appStore.loading = false
  }
}
</script>

<style lang="scss" scoped>
.home-page {
  padding: 0 !important;
  height: 100%;
  width: 100%;
}

.home-background {
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}
</style>

