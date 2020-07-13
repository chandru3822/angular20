<template>
  <v-container id="contacts-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Contacts</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newContact" color="primary" v-if="$store.getters.userHasFeatureAccessLevel('CONTACTS', 'ADD')">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Add Contact</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-3">
          <v-text-field
              class="mt-5"
              prepend-inner-icon="search"
              text
              label="Search contacts..."
              v-model="search"
              @input="debounceGetContacts"
          ></v-text-field>
          <v-spacer></v-spacer>
<!--          <v-toolbar-items>-->
<!--            <v-btn text v-if="totalContacts <= 100000" @click="exportContacts">Export</v-btn>-->
<!--            <v-dialog-->
<!--                v-model="dialog"-->
<!--                width="500"-->
<!--                v-else-->
<!--            >-->
<!--              <template v-slot:activator="{ on }">-->
<!--                <v-btn text v-on="on">-->
<!--                  Export-->
<!--                </v-btn>-->
<!--              </template>-->

<!--              <v-card>-->
<!--                <v-card-title>-->
<!--                  Export-->
<!--                </v-card-title>-->

<!--                <v-card-text>-->
<!--                  You are attempting to export {{totalContacts | currency('', 0)}} results.-->
<!--                  This can take 1-2 minutes.-->
<!--                  We recommend that you cancel and filter the result set before exporting.-->
<!--                </v-card-text>-->

<!--                <v-divider></v-divider>-->

<!--                <v-card-actions>-->
<!--                  <div class="flex-grow-1"></div>-->
<!--                  <v-btn-->
<!--                      color="grey"-->
<!--                      text-->
<!--                      @click="dialog = false"-->
<!--                  >-->
<!--                    Cancel-->
<!--                  </v-btn>-->
<!--                  <v-btn-->
<!--                      color="primary"-->
<!--                      text-->
<!--                      @click="exportContacts"-->
<!--                  >-->
<!--                    Continue Anyway-->
<!--                  </v-btn>-->
<!--                </v-card-actions>-->
<!--              </v-card>-->
<!--            </v-dialog>-->
<!--          </v-toolbar-items>-->
        </v-toolbar>
        <v-data-table
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

            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.fullName}}</td>
              <td class="text-left">{{item.owner ? item.owner.fullName : ''}}</td>
              <td class="text-left">{{item.state}}</td>
              <td class="text-left">{{item.dateCreated | formatDate('date')}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import debounce from 'lodash.debounce'
import { saveAs } from 'file-saver'

export default {
  name: 'Contacts',
  components: {
    Snackbar
  },
  data () {
    return {
      delay: 500,
      constants,
      dialog: false,
      snackbar: {},
      contacts: [],
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
      search: ''
    }
  },
  watch: {
    options: {
      handler () {
        this.getContacts()
      },
      deep: true,
    },
  },
  methods: {
    clickRow(id){
      this.$router.push({name: 'contact', params: {id}})
    },
    debounceGetContacts: debounce( function () {
      this.dataLoading = true
      this.getContacts()
    }, 500),
    async getContacts () {
      const { sortBy, sortDesc, page, itemsPerPage } = this.options
      try {
        const {data} = await getRequestWithParams(`/contact/search`, { params: {
            query: this.search,
            page: page - 1,
            size: itemsPerPage
        }})
        this.contacts = data.content
        this.totalContacts = data.totalElements
        this.dataLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Contacts')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async exportContacts () {
      this.dialog = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/contact/exportContacts`, { params: {
            query: this.search
        }})
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        });
        saveAs(blob, "contacts.csv");
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Contacts')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss">
  #contacts-container .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
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

