<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addNew = !addNew; newType = {}">
            {{addNew ? 'Cancel' : 'Add New'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container>
        <v-text-field v-if="addNew"
                      v-model="newType.attachmentType"
                      placeholder="Enter a type"
                      label="Attachment Type">
        </v-text-field>
        <v-btn v-if="addNew" :disabled="!newType.attachmentType" @click="addNewType">Save</v-btn>
        <v-list v-for="(a, index) in filterBy(attachmentTypes, false, 'archived')"
                :key="index">
          <v-list-item>
            <v-list-item-content>
              <v-text-field class="one-hunned" v-if="selectedAttachmentTypeId === a.id" v-model="a.attachmentType">
              </v-text-field>
              <div v-else>{{a.attachmentType}}</div>
            </v-list-item-content>
            <v-list-item-action class="clickable">
              <v-icon v-if="selectedAttachmentTypeId === a.id" @click="saveType(a)">save</v-icon>
              <v-icon v-else @click="selectedAttachmentTypeId = a.id">edit</v-icon>
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
                  Are you sure you want to delete this attachment type: <strong>{{ a.attachmentType }}</strong>?
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
                      @click="a.archived = true; deleteType(a.id)">
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
      attachmentTypes: [],
      addNew: false,
      newType: {},
      selectedAttachmentTypeId: null,
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId
    }
  },
  computed: {
  },
  methods: {
    async getAttachmentTypes () {
      const {data} = await getRequest(`/api/v1/flow/${this.companyId}/attachmentType/types`)
      this.attachmentTypes = orderBy(data, [a => a.attachmentType.toLowerCase()])
    },
    async deleteType (typeId) {
      await deleteRequest(`/api/v1/flow/${this.companyId}/attachmentType/type/${typeId}`)
    },
    async addNewType () {
      this.newType.companyId = this.companyId
      // this.newProcess.createdById = this.userId
      const {data} = await postRequest(`/api/v1/flow/${this.companyId}/attachmentType/type`, this.newType)

      // add it to the records already on the screen
      this.attachmentTypes.push(data)
      this.attachmentTypes = orderBy(this.attachmentTypes, [a => a.attachmentType.toLowerCase()])

      // reset the new process fields
      this.addNew = false
      this.newType = {}
    },
    async saveType (a) {
      this.selectedAttachmentTypeId = null
      a.modifiedById = this.userId
      await putRequest(`/api/v1/flow/${this.companyId}/attachmentType/type`, a)
    }
  },
  async created () {
    this.getAttachmentTypes()
  }
}
</script>

<style scoped lang="scss">

</style>
