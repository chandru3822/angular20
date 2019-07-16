<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Links</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addNew = !addNew; newLink = {}">
            {{addNew ? 'Cancel' : 'Add New'}}
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
                      placeholder="Enter a url"
                      label="Url">
        </v-text-field>
        <v-btn v-if="addNew" :disabled="!newLink.link || !newLink.url" @click="addNewLink">Save</v-btn>
        <v-list v-for="(a, index) in filterBy(links, false, 'archived')"
                :key="index">
          <v-list-item>
            <v-list-item-content>
              <v-text-field class="one-hunned" v-if="selectedLinkId === a.id"
                            label="Link"
                            v-model="a.link">
              </v-text-field>
              <v-text-field class="one-hunned" v-if="selectedLinkId === a.id"
                            label="Url"
                            v-model="a.url">
              </v-text-field>
              <div v-else>{{a.link}}</div>
            </v-list-item-content>
            <v-list-item-action class="clickable">
              <v-icon v-if="selectedLinkId === a.id" @click="saveLink(a)">save</v-icon>
              <v-icon v-else @click="selectedLinkId = a.id">edit</v-icon>
            </v-list-item-action>
            <v-dialog
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
                      color="primary"
                      text
                      @click="a.archived = true; deleteLink(a.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-container>
    </v-flex>
  </v-layout>
</template>


<script>
  import {mapState} from 'vuex'
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import {getRequest, deleteRequest, putRequest, postRequest} from '@/helpers/helpers'

  export default {
    name: 'Attachments',
    mixins: [Vue2Filters.mixin],
    data () {
      return {
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
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/links`)
        this.links = orderBy(data, [a => a.link.toLowerCase()])
      },
      async deleteLink (typeId) {
        await deleteRequest(`/api/v1/flow/companies/${this.companyId}/links/${typeId}`)
      },
      async addNewLink () {
        this.newLink.companyId = this.companyId
        // this.newProcess.createdById = this.userId
        const {data} = await postRequest(`/api/v1/flow/companies/${this.companyId}/links`, this.newLink)

        // add it to the records already on the screen
        this.links.push(data)
        this.links = orderBy(this.links, [a => a.link.toLowerCase()])

        // reset the new process fields
        this.addNew = false
        this.newLink = {}
      },
      async saveLink (a) {
        this.selectedLinkId = null
        a.modifiedById = this.userId
        await putRequest(`/api/v1/flow/companies/${this.companyId}/links`, a)
      }
    },
    async created () {
      this.getLinks()
    }
  }
</script>

<style scoped lang="scss">

</style>
