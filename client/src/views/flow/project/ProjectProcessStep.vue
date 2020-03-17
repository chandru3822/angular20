<template>
<v-row>

<!--  screen header -->
  <v-col cols="12">
    <v-row class="process-step-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/contact/${contact.id}`">{{ contact.fullName}}</router-link>
        </div>
        <div class="project-subtitle">
          {{ contact.street1 }} - {{ contact.city }}, {{ contact.state }}
        </div>
      </v-col>

      <v-col cols="4" class="lead-owner pb-2 text-right">
        <div v-if="!displayChangeOwner">
          <div v-if="processStep.owner && processStep.owner.userId">
            <v-avatar
              :tile="false"
              :size="25"
              color="grey lighten-4"
              class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
            </v-avatar>
            {{processStep.owner.fullName}}<br/>
            {{processStep.owner.position}}
          </div>
        </div>
        <div v-if="displayChangeOwner">
          <v-autocomplete v-model="processStep.owner"
                          :items="availableOwners"
                          label="Select Owner"
                          item-text="fullName"
                          return-object
                          autocomplete="off"
                          @change="updateOwner"
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small class="change-owner-button" @click="displayChangeOwner = !displayChangeOwner">
          <span v-if="displayChangeOwner">cancel</span>
          <span v-else-if="contact.owner && contact.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
      </v-col>
    </v-row>
  </v-col>

  <v-col class="text-left">
    <router-link :to="`/project/${projectId}`">Back</router-link>
  </v-col>

  <v-col cols="12" class="text-left">
    <h2>{{ processStep.processStepName }}</h2>
  </v-col>

  <v-col cols="12" lg="6" class="text-left">

<!--    process field groups-->
    <v-col
      class="mt-4"
      v-for="(cfg, index) in customFieldGroups"
      :key="cfg.id"
    >
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>
<!--  @TODO: @humes, once schedule tool is ready, have this link go to a more specific location in the schedule tool-->
          <router-link v-if="cfg.eventTypeId" :to="`/schedule`">{{cfg.groupName}}</router-link>
          <template v-else>{{cfg.groupName}}</template>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn
            v-if="index === 0"
            text
            @click="updateFieldGroups"
          >Save Process Fields</v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="pa-4">
        <CustomValueInput
          v-for="(field, idx) in cfg.customFieldValues"
          :key="idx"
          :readonly="field.ancillaryCustomFieldGroupAssignmentId !== null"
          :field="field"
        />
      </v-card>
    </v-col>

    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Actions</v-toolbar-title>
    </v-toolbar>
    <v-col v-for="action in processStep.actions" :key="action.id">
      <ActionButton
        v-if="action.actionTypeId === 2"
        :actionId="action.id"
        :projectProcessStepId="parseInt(projectProcessStepId)"
        :label="action.actionName"
        :handleOnComplete="handleActionCompleted"
        :handleOnCompleteError="handleOnCompleteError"
      />
    </v-col>

    <!-- todo: @humes just putting this here so i can test scheduling.  feel free to do what you want with it. i dont even know if this is the right spot -->
    <!-- @TODO: @randa, Uncommenting for now until I can add it in programatically. How do we not hardcode the processStepid and projectId vals? (they harcoded for testing?)   -->
<!--    <v-row>-->
<!--      <v-col cols="12">-->

<!--        <h3>Links</h3>-->

<!--        <v-btn :to="{name: 'schedule', query: { processStepId: 1, projectId: 171704 } }">-->
<!--          Test link to schedule screen-->
<!--        </v-btn>-->
<!--      </v-col>-->
<!--    </v-row>-->

    <v-row>
      <Attachments :projectProcessStepId="parseInt(projectProcessStepId)" :processStepId="parseInt(processStepId)"/>
    </v-row>
  </v-col>

  <v-col cols="12" lg="6" class="text-left">
    <NotesAndActivity
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectProcessStepId)"
      type="ProjectProcessStep"
    />
  </v-col>

  <Snackbar :snackbar="snackbar"></Snackbar>
</v-row>
</template>

<script>

import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import CustomValueInput from '@/views/flow/components/CustomValueInput'

export default {
  name: 'ProjectProcessStep',
  components: {
    ActionButton,
    Snackbar,
    Attachments,
    NotesAndActivity,
    CustomValueInput
  },
  data () {
    return {
      snackbar: {},
      projectId: this.$route.params.projectId,
      projectProcessStepId: this.$route.params.processStepId,
      processStepId: this.$route.query.processStepId,
      processStep: {},
      customFieldGroups: [],
      isProcessStepLoading: true,
      notes: [],
      contact: {},
      displayChangeOwner: false,
      availableOwners: []
    }
  },
  async created () {
    this.getCustomFieldGroups()
    this.getNotes()
    this.getContact()
    await this.getProcessStep()
    this.getAvailableOwners()
  },
  methods: {
    getProcessStep: async function() {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}`)
        this.processStep = data
      } catch (e) {
        logError(e)
      } finally {
        this.isProcessStepLoading = false
      }
    },
    async getCustomFieldGroups() {
      //@TODO: @humes, make this use local loading so entire screen isn't blocked waiting
      //this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/project/${this.projectId}/processStep`, { params: {
            projectProcessStepId: this.projectProcessStepId
          }})
        this.customFieldGroups = data
        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getNotes() {
      try {
        const {data} = await getRequestWithParams(`/note/getProjectProcessStepNotes`, {
          params: {
            primaryId: this.projectProcessStepId
          }
        })
        this.notes = data
      } catch {
        console.log('suck')

      }
    },
    async getContact () {
      // this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/contact/${this.$route.query.contactId}`)
        this.contact = data
        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Contact')
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableOwners () {
      // this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/projectProcessStep/owners/${this.processStep.processStepProcessId}`)
        this.availableOwners = data

        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving List of Owners')
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateProjectFieldGroups() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.customFieldGroups)
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Update Project Fields')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.processStep.customFieldGroups = this.customFieldGroups
      try {
        await putRequest(`/projectProcessStep`, this.processStep)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$root.$emit('projectProcessStep:checkAction')
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateOwner() {
      this.displayChangeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/projectProcessStep/${this.projectProcessStepId}/owner`, this.processStep.owner)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    handleActionCompleted () {
      this.$router.push({name: 'projectOverview', params: {projectId: this.projectId}})
    },
    handleOnCompleteError (actionId) {
      logError(`Failed to complete action with actionId: ${actionId}`)
      this.snackbar = getSnackbar('ERROR', 'Unable to Complete Action')
    }
  }
}
</script>

<style lang="scss" scoped>
.process-step-header {
  border-bottom: solid 1px #EAEAF4;
}
</style>
