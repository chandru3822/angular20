<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Links</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newLink = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newLink.link"
                        placeholder="Enter a link name"
                        label="Link">
          </v-text-field>
          <v-text-field v-if="addNew"
                        v-model="newLink.url"
                        placeholder="Enter a URL"
                        label="URL">
          </v-text-field>
          <v-btn v-if="addNew" :disabled="!newLink.link || !newLink.url" @click="addNewLink">Save</v-btn>
          <v-list v-for="(a, index) in filterBy(links, false, 'archived')"
                  :key="index"  class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left">
                <v-text-field class="one-hunned" v-if="selectedLinkId === a.id"
                              label="Link"
                              v-model="a.link">
                </v-text-field>
                <v-text-field class="one-hunned" v-if="selectedLinkId === a.id"
                              label="URL"
                              v-model="a.url">
                </v-text-field>
                <div v-else>{{a.link}}</div>
              </v-list-item-content>
              <v-list-item-action class="clickable" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                <v-icon v-if="selectedLinkId === a.id" @click="saveLink(a)">save</v-icon>
                <v-icon v-else @click="selectedLinkId = a.id">edit</v-icon>
              </v-list-item-action>
              <v-dialog
                  v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                  v-model="a.deleteConfirm"
                  width="500">
                <template v-slot:activator="{ on }">
                  <v-list-item-action class="clickable" v-on="on">
                    <v-icon>delete</v-icon>
                  </v-list-item-action>
                </template>
                <v-card>
                  <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete this link: <strong>{{ a.link }}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="a.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primaryCustom"
                        text
                        @click="[a.archived = true, deleteLink(a.id)]">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'

  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'Links',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        constants,
        links: [],
        addNew: false,
        newLink: {},
        selectedLinkId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId
      }
    },
    computed: {
    },
    methods: {
      async getLinks () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/links`)
          this.links = orderBy(data, [a => a.link.toLowerCase()])
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteLink (typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/links/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Link Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewLink () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newLink.companyId = this.companyId
          // this.newProcess.createdById = this.userId
          const {data, status} = await postRequest(`/links`, this.newLink)

          // add it to the records already on the screen
          this.links.push(data)
          this.links = orderBy(this.links, [a => a.link.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newLink = {}
          this.snackbar = getSnackbar('SUCCESS', 'Link Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Link')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveLink (a) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedLinkId = null
          a.modifiedById = this.userId
          const {status} = await putRequest(`/links`, a)
          this.snackbar = getSnackbar('SUCCESS', 'Link Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Link')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created () {
      this.getLinks()
    }
  }
</script>

