<template id="account-menu">
  <v-menu data-app left
          offset-y
          :max-height="`calc(100vh - 50px)`"
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <a-btn
          class="account-menu-button label-medium"
          id="tools-menu-btn"
          :color="headerColor"
          :custom-classes="isMobile ? 'mobile-tools-button' : 'fake-inactive'"
          :x-small="isMobile"
          :activation-handler="on"
      >
        <template #default>
          TOOLS
          <v-icon>mdi-chevron-down</v-icon>
        </template>
      </a-btn>
    </template>
    <div>
      <v-list>
        <v-list-item v-for="(item, index) in mutableCompanyTools"
                     :class="{'pa-0': item.featureCode === 'TOURNAMENTS' || item.featureCode ==='DATABASES'}"
                     :key="index" @click="closeMenu(item)"
                     :to="item.featurePath">
          <v-list-item-title v-if="item.featureCode !== 'TOURNAMENTS' && item.featureCode !== 'DATABASES'">{{item.featureName}}</v-list-item-title>

          <v-list-group
              v-else-if="item.featureCode === 'TOURNAMENTS'"
              class="pa-0"
              :value="false"
              @click="loadBrsTournaments"
          >
            <template v-slot:activator>
              <v-list-item-title >{{item.featureName}}</v-list-item-title>
            </template>

            <v-list-item v-if="tourneysLoading">
              <v-list-item-title>
                <SpinnerInline :size="20" color="primary"/>
              </v-list-item-title>
            </v-list-item>

            <v-list-item v-if="!tourneysLoading && tournaments.length === 0">
              <v-list-item-title class="px-7">
                No Active Tournaments
              </v-list-item-title>
            </v-list-item>

            <v-list-item
                v-else-if="!tourneysLoading"
                v-for="(t, i) in tournaments"
                :key="i"
                class="px-7"
                @click="closeMenu(t)"
                :to="`/tournament/${t.id}`"
                link
            >
              <v-list-item-title>{{t.tournamentName}}</v-list-item-title>
            </v-list-item>
          </v-list-group>
          <v-list-group
              v-else
              class="pa-0"
              :value="false"
              @click="loadDatabaseOptions(index)"
              style="width: 100%"
          >
            <template v-slot:activator>
              <v-list-item-title >{{item.featureName}}</v-list-item-title>
            </template>


            <v-list-item
                v-for="(t, i) in databaseOptions"
                :key="i"
                class="px-7"
                @click="closeMenu(t)"
                :to="`${databasePaths[i]}`"
                link
            >
              <v-list-item-title>{{t}}</v-list-item-title>
            </v-list-item>
          </v-list-group>
        </v-list-item>
      </v-list>
    </div>
  </v-menu>
</template>

<script setup>
import constants from '@/helpers/constants'
import Vue2Filters from 'vue2-filters'
import SpinnerInline from '@/components/SpinnerInline'
import { getRequest,  } from '@/helpers/helpers'


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

const props = defineProps({
  companyTools: Array,
  isMobile: Boolean

})
const { companyTools, isMobile } = toRefs(props)

const tournaments = ref([])
const tourneysLoading = ref(false)
const loadComplete = ref(false)
const mutableCompanyTools = ref(companyTools.value)
const headerColor = ref(constants.ENV_COLOR)
const menuOpen = ref(false)
const databaseLoaded = ref(false)
const databaseOptions = ref([])
const databasePaths = ref([])

onMounted(() => {
  filterForParents();
})

const closeMenu = (item) => {
  if(item.featureCode !== 'TOURNAMENTS' && item.featureCode !== 'DATABASES') {
    menuOpen.value = false
  }
}
const loadBrsTournaments = async() => {
  tourneysLoading.value = true
  try {
    const {data} = await getRequest('/tournament/active', 'blueraven')
    tournaments.value = data
    tourneysLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Tournaments')
    tourneysLoading.value = false
  }
}
const loadDatabaseOptions = async(index) => {
  databaseOptions.value = mutableCompanyTools.value[index].childNames.slice().reverse();
  databasePaths.value = mutableCompanyTools.value[index].childPaths.slice().reverse();
}
const filterForParents = async() => {
  appStore.loading = true
  let filteredTools = companyTools.value.slice().reverse();
  let lastName = " ";
  companyTools.value?.slice().reverse().forEach(
      x => {
        if (x.featureName == lastName) {
          filteredTools.splice(filteredTools.indexOf(x), 1);
        }
        lastName = x.featureName;
      }
  )
  mutableCompanyTools.value = filteredTools.reverse();
  appStore.loading = false
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}

.v-list .v-list-item--active{
  color:var(--v-anchor-base);
  background-color: var(--v-primary-lighten9);
}
.account-menu-button{
  text-transform: capitalize;
  box-shadow: none !important;
  -webkit-box-shadow: none !important;
  border: none !important;
}
.fake-inactive {
  opacity: .6;
}
.mobile-tools-button {
  padding-left: 8px !important;
  padding-right: 4px !important;
}
</style>
