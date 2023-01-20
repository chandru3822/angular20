<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Links</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newLink = { url: ''}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card v-if="addNew" flat color="transparent">
            <v-text-field v-model="newLink.link"
                          placeholder="Enter a link name"
                          label="Link">
            </v-text-field>
            <v-text-field v-model="newLink.url"
                          clearable
                          placeholder="Enter a URL"
                          label="URL">
            </v-text-field>
            <div>
              These parameters can be used to add some system values to a url. <br/>
              Validation is not yet in place so be careful which screens you assign a url to. <br/>
              For example, you should not add a url using "Project Process Step Event ID" to a Process Step. <br/>
              <v-btn color="primary" v-for="p in linkParams" @click="updateUrl(newLink, p.code)" class="ma-2">
                {{p.name}}
              </v-btn>
            </div>
            <v-btn color="primary" class="mt-4" :disabled="!newLink.link || !newLink.url" @click="addNewLink">Save</v-btn>
          </v-card>
          <div v-else>
            <v-list v-for="(a, index) in filterBy(links, false, 'archived')"
                    :key="index"  class="pa-0">
              <v-list-item :class="{'shaded-row': index % 2}">
                <v-list-item-content class="text-left">
                  <div v-if="selectedLinkId === a.id">
                    <v-text-field class="one-hunned"
                                  label="Link"
                                  v-model="a.link">
                    </v-text-field>
                    <v-text-field class="one-hunned"
                                  label="URL"
                                  clearable
                                  v-model="a.url">
                    </v-text-field>
                    <div>
                      These parameters can be used to add some system values to a url. <br/>
                      Validation is not yet in place so be careful which screens you assign a url to. <br/>
                      For example, you should not add a url using "Project Process Step Event ID" to a Process Step. <br/>
                      <v-btn color="primary" v-for="p in linkParams" @click="updateUrl(a, p.code)" class="ma-2">
                        {{p.name}}
                      </v-btn>
                    </div>
                  </div>
                  <div v-else>{{a.link}}</div>
                </v-list-item-content>
                <v-list-item-action class="clickable" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                  <v-btn text color="primary" :disabled="!a.url || !a.link" v-if="selectedLinkId === a.id" @click="saveLink(a)">
                    <v-icon>save</v-icon>
                  </v-btn>
                  <v-icon v-else color="primary" @click="selectedLinkId = a.id">edit</v-icon>
                </v-list-item-action>
                <v-btn small text color="primary"
                       v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                       @click="linkToDelete=a">
                  <v-icon>delete</v-icon>
                </v-btn>
              </v-list-item>
            </v-list>
          </div>
          <ConfirmationDialog :open-dialog="!!linkToDelete" @confirm="deleteLink" @close-dialog="linkToDelete=null">
            Are you sure you want to delete this link: <strong>{{linkToDeleteValue}}</strong>?
          </ConfirmationDialog>
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
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'Links',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        constants,
        links: [],
        addNew: false,
        newLink: { url: '' },
        //hard coding these for now till we figure out what we want to do
        linkParams: [
          { name: 'Albatross Base URL', code: 'ALB_HOST'},
          { name: 'Contact ID', code: 'ALB_CONTACT_ID'},
          { name: 'Project ID', code: 'ALB_PROJECT_ID'},
          { name: 'Project Process Step ID', code: 'ALB_PPS_ID'},
          { name: 'Project Process Step Event ID', code: 'ALB_PPSE_ID'},
        ],
        selectedLinkId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        linkToDelete: null
      }
    },
    computed: {
      linkToDeleteValue(){
        return this.linkToDelete ? this.linkToDelete.link : ''
      }
    },
    methods: {
      updateUrl(item, code) {
        item.url == null ? item.url = code : item.url += code
      },
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
      async deleteLink () {
        const link = this.linkToDelete
       const typeId= this.linkToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/links/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Link Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          link.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.linkToDelete = null
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
          this.newLink = { url: ''}
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

