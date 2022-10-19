<template>
  <div>
    <v-toolbar flat color="transparent">
      <v-toolbar-title class="app-title">
        SMS Messages
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text color="primary" v-if="!addChildSms && userCanAdd"
               @click="[addChildSms = true, loadChildTemplates()]">
          <v-icon>add</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-card flat class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
            v-if="addChildSms">
      <h3>Add Child Sms</h3>
      <v-autocomplete v-model="selectedTemplate"
                      :items="childSmsTemplates"
                      label="SMS Template"
                      item-text="title"
                      item-value="id"
                      return-object
                      @input="selectedTeams=[]"
                      attach
      ></v-autocomplete>
      <v-autocomplete v-if="selectedTemplate.id"
                      v-model="selectedTeams"
                      :items="selectedTemplate.teams"
                      label="Select SMS Team(s)"
                      item-text="teamName"
                      item-value="id"
                      multiple
                      return-object
                      attach
      ></v-autocomplete>
      <div class="mt-3">
        <v-btn :disabled="!selectedTemplate.id" color="primary"
               @click="saveSmsToAction()">
          <v-icon>save</v-icon>
          Save
        </v-btn>
        <v-btn class="ml-3" @click="addChildSms = false" text color="primary">
          <v-icon>remove</v-icon>
          Cancel
        </v-btn>
      </div>
    </v-card>
    <v-row justify="center" class="pl-3 pr-3"
           v-if="action.processStepActionChildSmsTemplates && action.processStepActionChildSmsTemplates.length > 0">
      <v-col cols="12" class="pt-0">
        <v-list v-for="(cp, index) in filterBy(action.processStepActionChildSmsTemplates, false, 'archived')"
                :key="index"
                :class="{ 'shaded-row': index % 2 }">
          <v-list-item>
            <v-list-item-content class="text-left pb-0">
              <v-list-item-title>
                {{ cp.title }}
              </v-list-item-title>
              <v-list-item-content class="pb-0">
                <div class="d-flex">
                  Teams:
                  <p class="d-flex ml-2">
                    <span v-for="(team, idx) in cp.teams">
                    <span v-if="idx !== 0">,</span>
                      {{ team.teamName }}
                    </span>
                  </p>
                </div>
              </v-list-item-content>
            </v-list-item-content>

            <v-dialog
              v-if="userCanEdit"
              v-model="cp.deleteConfirm"
              width="500">
              <template v-slot:activator="{ on }">
                <v-list-item-action class="clickable" v-on="on">
                  <v-icon>delete</v-icon>
                </v-list-item-action>
              </template>
              <v-card>
                <v-card-title
                  class="text-h5 grey lighten-2"
                  primary-title
                >
                  Confirm
                </v-card-title>

                <v-card-text>
                  Are you sure you want to delete <strong>{{ cp.title }}</strong> from <strong>{{
                    action.actionName
                  }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                    @click="cp.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                    color="primary"
                    text
                    @click="[cp.archived = true, deleteSmsFromAction(cp.id)]">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import cloneDeep from 'lodash.clonedeep'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import ProcessStepRequirements from './ProcessStepRequirements'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ActionChildSms',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    ProcessStepRequirements
  },
  props: {
    selectedActionIndex: Number,
    action: Object,
    processStepId: Number,
    addSmsCallback: Function,
    deleteSmsCallback: Function,
  },
  data() {
    return {
      snackbar: {},
      addChildSms: false,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      selectedTemplate: {},
      selectedTeams: [],
      childSmsTemplates: [],
    }
  },
  computed: {},
  async created() {
  },
  methods: {
    async loadChildTemplates() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/messaging/templatesWithTeams`)
        this.childSmsTemplates = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Templates')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveSmsToAction() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {
          data,
          status
        } = await postRequest(`/processStep/${this.processStepId}/action/${this.action.id}/addSmsToAction`, {
          messageTemplateId: this.selectedTemplate.id,
          teamIds: this.selectedTeams.map(m => m.id)
        })
        this.addSmsCallback(this.action.id, data)
        this.selectedTemplate = {}
        this.selectedTeams = []
        this.snackbar = getSnackbar('SUCCESS', 'SMS Template Added To Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding SMS Template to Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteSmsFromAction(id) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/processStep/${this.processStepId}/action/${this.action.id}/deleteSms/${id}`)
        this.deleteSmsCallback(this.action.id, id)
        this.snackbar = getSnackbar('SUCCESS', 'SMS Template Deleted From Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting SMS Template From Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }

}
</script>

<style scoped lang="scss">

</style>
