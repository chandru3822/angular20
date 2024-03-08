<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-breadcrumbs :items="breadcrumbs" color="primary"></v-breadcrumbs>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large text-wrap">{{ tournament.tournamentName }}</v-toolbar-title>
        </v-toolbar>
        <v-tabs id="tournaments-tabs" class="tabs-bar">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>

        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  getRequest,
  getSnackbar
} from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useRoute} from "vue-router/composables";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const route = useRoute()

const tournament = ref({})
const tournamentId = ref(parseInt(route.params.id))
const userId = ref(store.state.user.details.id)
const tabs = ref([
  {
    label: 'Details',
    path: `/settings/tournaments/${route.params.id}/details`,
  },
  {
    label: 'Brackets',
    path: `/settings/tournaments/${route.params.id}/brackets`,
  },
  {
    label: 'Qualifying',
    path: `/settings/tournaments/${route.params.id}/pool/1`,
  },
  {
    label: 'Last Chance',
    path: `/settings/tournaments/${route.params.id}/pool/2`,
  },
  {
    label: 'Winner',
    path: `/settings/tournaments/${route.params.id}/pool/3`,
  }
])
const breadcrumbs = ref([
  {
    text: 'Back to Tournaments',
    disabled: false,
    exact: true,
    to: `/settings/tournaments`
  }
])

onMounted(() => {
  getTournament()
})

const timezone = computed(() => {
  return userStore.details.timezone?.value
})

const getTournament = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}`, 'blueraven')
    tournament.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Loading Tournament')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

</script>

<style scoped lang="scss">
.tabs-bar {
  top: -12px;
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;

  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
<style lang="scss">
@media (max-width: 959px) {
  #tournaments-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #tournaments-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
}
</style>
