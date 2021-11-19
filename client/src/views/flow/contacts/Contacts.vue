<template>
  <v-container id="contacts-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1 toolbar-z-index-override">
          <v-toolbar-title class="app-title">Contacts</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-autocomplete
              v-if="$store.getters.userHasFeature('SMARTLIST')"
              v-model="selectedSmartlistId"
              :items="smartlists"
              item-text="name"
              item-value="id"
              class="smartlist-selector pt-3"
              attach
            />
            <v-btn text v-if="canAdd && (!$store.getters.isParent(parentId) || !companies || companies.length === 1)"
                   to="/newContact" color="primaryCustom">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Add Contact</span>
            </v-btn>
            <v-menu data-app left
                    v-else-if="canAdd && companies && companies.length > 1"
                    offset-y
                    v-model="menuOpen"
                    max-height="350"
                    class="account-menu"
                    :close-on-content-click="false">
              <template v-slot:activator="{ on }">
                <v-btn text v-on="on">
                  <v-icon>add</v-icon>
                  <span v-if="!constants.IS_MOBILE">Add Contact</span>
                </v-btn>
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
          v-if="selectedSmartlistId === 0"
          color="white"
          class="elevation-1 mt-3"
        >
          <v-text-field
              class="mt-5"
              prepend-inner-icon="search"
              text
              clearable
              label="Search contacts..."
              v-model="search"
              @input="debounceGetContacts"
          ></v-text-field>
          <v-spacer></v-spacer>
        </v-toolbar>
        <v-data-table
            v-if="selectedSmartlistId === 0"
            :headers="headers"
            :items="contacts"
            :fixed-header="true"
            :options.sync="options"
            disable-sort
            :mobile-breakpoint="0"
            :footer-props="footerProps"
            :loading="dataLoading"
            :server-items-length="totalContacts"
            class="elevation-1 fix-column-width-bug contact-table"
        >
          <template #no-data>
            No available contacts
          </template>

          <template #no-results>
            No available contacts
          </template>

          <template #item="{ item, index }">

            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card"
                             color="transparent" :to="`/contact/${item.id}`">
                  {{item.fullName}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card"
                             color="transparent" :to="`/contact/${item.id}`">
                  {{item.owner ? item.owner.fullName : ''}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card"
                             color="transparent" :to="`/contact/${item.id}`">
                  {{item.state}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card"
                             color="transparent" :to="`/contact/${item.id}`">
                  {{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}
                </router-link>
              </td>
            </tr>
          </template>
        </v-data-table>

        <SmartlistTable
          class="mt-3"
          :type="'CONTACT'"
          v-else
          :smartlistId="selectedSmartlistId"
          @row-selected="goToContact"
        />
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'

import {
  handleHidingGlobalLoader,
  getRequestWithParams,
  getSnackbar,
  logError,
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import debounce from 'lodash.debounce'
import { saveAs } from 'file-saver'
import SmartlistTable from '@/components/SmartlistTable'

export default {
  name: 'Contacts',
  components: {
    SmartlistTable
  },
  data () {
    return {
      initialLoad: true,
      delay: 500,
      constants,
      menuOpen: false,
      companies: this.$store.state.user.companies,
      canAdd: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'ADD'),
      dialog: false,
      snackbar: {},
      contacts: [],
      parentId: this.$store.state.user.details.parentCompanyId,
      descending: true,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 1000],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      options: {
        itemsPerPage: 100
      },
      totalContacts: 0,
      dataLoading: true,
      headers: [
        { text: 'Contact Name', value: 'fullName', show: true },
        { text: 'Owner', value: 'ownerFullName', show: true },
        { text: 'State', value: 'state', show: true },
        { text: 'Date Created', value: 'dateCreated', show: true },
      ],
      search: '',
      selectedSmartlistId: 0,
      smartlists: [{id: 0, name: 'Default View'}]
    }
  },
  watch: {
    options: {
      handler () {
        if(!this.initialLoad) {
          this.getContacts()
        }
      },
      deep: true,
    },
  },
  beforeRouteEnter(to, from, next) {
    //if coming to this page from the contact details - use the previously used search
    next((vm) => {
      if(from?.fullPath.includes('/contact/')) {
        vm.search = localStorage.getItem('contactSearch') || ''
      } else {
        localStorage.removeItem('contactSearch')
      }
      vm.getContacts()
    });
  },
  created () {
    if (this.$store.getters.userHasFeature('SMARTLIST')) {
      this.getSharedSmartlists()
    }
  },
  methods: {
    async getSharedSmartlists() {
      try {
        const {data} = await getRequestWithParams(`/smartlist/shared`, {params: {objectTypeId: 2}}, null, [])
        this.smartlists = [...this.smartlists, ...data]
      } catch (e) {
        logError(e)
      }
    },
    clickRow(id){
      this.$router.push({name: 'contact', params: {id}})
    },
    debounceGetContacts: debounce( function () {
      this.dataLoading = true
      //don't allow search to be null - causes issues
      this.search = this.search || ''
      localStorage.setItem('contactSearch', this.search)
      this.getContacts()
    }, 500),
    async getContacts () {
      const { sortBy, sortDesc, page, itemsPerPage } = this.options
      try {
        const {data, status} = await getRequestWithParams(`/contact/search`, { params: {
            query: this.search,
            page: page - 1,
            size: itemsPerPage
        }}, null, [])
        this.contacts = data.content || []
        this.totalContacts = data.totalElements
        this.dataLoading = false
        this.initialLoad = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Contacts')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async exportContacts () {
      this.dialog = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/contact/exportContacts`, { params: {
            query: this.search
        }})
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        });
        saveAs(blob, "contacts.csv");
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Contacts')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    goToContact (selectedRow) {
      this.$router.push({name: 'contact', params: {id: selectedRow.contact_id}})
    }
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
  }


</style>

