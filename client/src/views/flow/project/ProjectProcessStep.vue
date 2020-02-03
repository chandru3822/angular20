<template>
<v-row>
  <v-col class="text-left">
    <router-link :to="`/project/${projectId}`">Back</router-link>
  </v-col>

  <v-col cols="12" class="text-left">
    <h3>{{ processStep.name }}</h3>
  </v-col>


  <v-col cols="12" lg="6" class="text-left">

    <v-row v-for="(group, index) in customFieldGroups" :key="index">
<!--  @TODO: @randa, this is the reactjs way to do this. Does vue have a better way? -->
      <v-col>
        <ProcessStepFieldGroup :group="group" :onSaveHandler="randaSaveCustomFields"/>
      </v-col>
    </v-row>

    <h3>Actions</h3>

    <v-row>
      <v-col v-for="action in processStep.actions" :key="action.id">
        <ActionButton
          v-if="action.actionTypeId === 2"
          :actionId="action.id"
          :projectProcessStepId="projectProcessStepId"
          :label="action.actionName"
          :handleOnComplete="handleActionCompleted"
          :handleOnCompleteError="handleOnCompleteError"
        />
      </v-col>
    </v-row>

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

import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import ProcessStepFieldGroup from "./ProcessStepFieldGroup";

export default {
  name: 'ProjectProcessStep',
  components: {
    ActionButton,
    Snackbar,
    Attachments,
    NotesAndActivity,
    ProcessStepFieldGroup
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
      notes: []
    }
  },
  created () {
    this.getProcessStep()
    this.getCustomFieldGroups()
    this.getNotes()
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
    async randaSaveCustomFields() {
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
    handleActionCompleted () {
      this.$router.push({
        name: 'project',
        params: {
          projectId: this.projectId
        }
      })
    },
    handleOnCompleteError () {
      console.log('don blewed up!!!!')
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
