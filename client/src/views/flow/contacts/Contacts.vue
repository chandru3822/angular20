<template>
  <v-container id="contacts-container" style = "overflow-x: hidden; overflow-y: hidden">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1 toolbar-z-index-override">
          <v-toolbar-title class="title-large-medium">Contacts</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

            <a-btn
                id="qa-new-contact-single"
                variant="text"
                v-if="canAdd && (!userStore.isParent|| !companies || companies.length === 1)"
                to="/newContact"
                color="primary"
                :text="!constants.IS_MOBILE ? 'Add Contact' : ''"
            ></a-btn>
            <v-menu data-app left
                    v-else-if="canAdd && companies && companies.length > 1"
                    offset-y
                    v-model="menuOpen"
                    max-height="350"
                    class="account-menu"
                    :close-on-content-click="false">
              <template v-slot:activator="{ on }">
                <a-btn
                    id="qa-new-contact-multi"
                    variant="text"
                    :activation-handler="on"
                    color="primary"
                    prepend-icon="add"
                    :text="!constants.IS_MOBILE ? 'Add Contact' : ''"
                ></a-btn>
              </template>
              <v-list dense class="pa-3">
                <v-list-item  @click="menuOpen = false" :to="`/newContact?cid=${c.id}`"
                              v-for="(c, idx) in companies" :key="idx">
                  <v-list-item-content>
                    <v-list-item-title>{{ c.companyName }}</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </v-list>
            </v-menu>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar
            color="white"
            class="elevation-1 mt-3"
        >
          <a-text-field
              id="qa-contact-search"
              class="mt-5 body-large"
              prepend-inner-icon="search"
              clearable
              label="Search contacts..."
              v-model="search"
              @input="debounceGetContacts"
          ></a-text-field>
          <v-spacer></v-spacer>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="contacts"
            :fixed-header="true"
            ref="pageable-table"
            :page.sync="page"
            :options.sync="options"
            disable-sort
            :mobile-breakpoint="0"
            :footer-props="footerProps"
            :loading="dataLoading"
            :server-items-length="totalContacts"
            class="elevation-1 fix-column-width-bug contact-table body-small"
        >
          <template #no-data>
            <div class="default-text-color">No available contacts</div>
          </template>

          <template #no-results>
            <div class="default-text-color">No available contacts</div>
          </template>

          <template #item="{ item, index }">

            <tr class="clickable" :class="{'primary lighten-9': index % 2}" >
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/contact/${item.id}`">
                  {{item.fullName}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/contact/${item.id}`">
                  {{item.owner ? item.owner.fullName : ''}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/contact/${item.id}`">
                  {{item.state}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/contact/${item.id}`">
                  {{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}
                </router-link>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>


import {
  handleHidingGlobalLoader,
  getRequestWithParams,

} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import debounce from 'lodash.debounce'
import axios from 'axios'

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
const vuetify = vueInstance.$vuetify

const initialLoad = ref(true)
const delay = ref(500)
const menuOpen = ref(false)
const dialog = ref(false)
const contacts = ref([])
const descending = ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const page = ref(1)
const options = ref({itemsPerPage: 100})
const totalContacts = ref(0)
const dataLoading = ref(true)
const headers = ref([
  { text: 'Contact Name', value: 'fullName', show: true },
  { text: 'Owner', value: 'ownerFullName', show: true },
  { text: 'State', value: 'state', show: true },
  { text: 'Date Created', value: 'dateCreated', show: true },
])
const search = ref('')
const source = ref(null)

const companies = computed(() => {
  return userStore.companies
})
const canAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('CONTACTS', 'ADD')
})
const useSavedFilter = computed(() => {
  return route.params.useSavedFilter
})

watch(
    () => options,
    (newValue, oldValue) => {
      if (!initialLoad.value) {
        getContacts();
      }
    },
    { deep: true }
)
watch(page, async() => {
  //this will also scroll when the rows per page changes IF not on the first page, which is correct behavior since it is resetting the search page back to 0
  let table = vueInstance.$refs['pageable-table'];
  let wrapper = table.$el.querySelector('div.v-data-table__wrapper');
  vuetify.goTo(table, {container: wrapper}); // to header
})

onMounted(() => {
  if(useSavedFilter.value === 'true') {
    search.value = localStorage.getItem('contactSearch') || ''
  } else {
    localStorage.removeItem('contactSearch')
  }
  getContacts()
})


const clickRow = (id) => {
  router.push({name: 'contact', params: {id}})
}
const debounceGetContacts = debounce(async() => {
  dataLoading.value = true
  //don't allow search to be null - causes issues
  search.value = search.value || ''
  localStorage.setItem('contactSearch', search.value)
  getContacts()
}, 500)

const getContacts = async () => {
  const { page, itemsPerPage } = options.value

  if(source.value){
    source.value.cancel();
  }
  const CancelToken = axios.CancelToken;
  source.value = CancelToken.source();

  try {
    const {data, status} = await getRequestWithParams(`/contact/search`, {
      source: source.value,
      cancelToken: source.value.token,
      params: {
        query: search.value,
        page: page - 1,
        size: itemsPerPage
      }}, null, [])
    contacts.value = data.content || []
    totalContacts.value = data.totalElements
    dataLoading.value = false
    initialLoad.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Contacts')

    appStore.loading = false
  }
}
</script>

<style lang="scss">
#contacts-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
#contacts-container .v-data-footer__pagination {
  display: none !important;
}
</style>

<style lang="scss" scoped>
#contacts-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
.contact-table {
  margin-top: 2px;
  word-break: break-word;
}
</style>

