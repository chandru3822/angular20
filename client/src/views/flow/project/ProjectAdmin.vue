<template>
<v-row id="project-admin-container">
  <v-col cols="12">
    <v-row class="project-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/customer/${customer.id}`">{{ customer.fullName}}</router-link>
        </div>
        <div class="project-subtitle">
          {{ customer.street1 }} - {{ customer.city }}, {{ customer.state }}
        </div>
      </v-col>

      <v-col
        cols="4"
        class="lead-owner pb-2 text-right">
        <div v-if="!displayChangeOwner">
          <div v-if="project.owner && project.owner.userId">
            <v-avatar
              :tile="false"
              :size="25"
              color="grey lighten-4"
              class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
            </v-avatar>
            {{project.owner.fullName}}<br/>
            {{project.owner.position}}
          </div>
        </div>
        <div v-if="displayChangeOwner">
          <v-autocomplete v-model="project.owner"
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
          <span v-else-if="customer.owner && customer.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
      </v-col>
    </v-row>
  </v-col>

  <v-col cols="6">

    <v-btn
      class="primary"
    >
      Add Process Step
    </v-btn>

    <v-col cols="12">
      <template v-for="step in projectProcessStepsByName">
        <h4 class="text-left work-type-header">{{step.processStepName}}</h4>
        <ProjectProcessStepSnippet
          :steps="step.projectProcessSteps"
          :projectId="projectId"
          :customerId="customer.id"/>
      </template>
    </v-col>
  </v-col>
  <Snackbar :snackbar="snackbar"/>
</v-row>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, postRequest, getSnackbar, logError} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'

export default {
  name: 'ProjectAdmin.vue',
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      project: {},
      projectProcessSteps: [],
      customer: {},
      snackbar: {},
      displayChangeOwner: false,
      availableOwners: []
    }
  },
  components: {
    Snackbar,
    ProjectProcessStepSnippet
  },
  created () {
    this.getCustomer()
    this.getProject()
    this.getProjectProcessSteps()
    this.getAvailableOwners()
  },
  computed: {
    projectProcessStepsByName () {
      const names = [...new Set(this.projectProcessSteps.map(step => step.processStepName))]

      return names.map(processStepName => {
        return {
          processStepName,
          projectProcessSteps: this.projectProcessSteps.filter(step => step.processStepName === processStepName)
        }
      })
    }
  },
  methods: {
    getProject: async function () {
      try {
        const {data} = await getRequest(`/project/${this.projectId}`)
        this.project = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project')
      }
    },
    getProjectProcessSteps: async function () {
      try {
        const {data} = await getRequest(`/project/${this.projectId}/processSteps`)
        this.projectProcessSteps = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching process steps')
      }
    },
    getCustomer: async function () {
      try {
        const{data} = await getRequest(`/customer/project/${this.projectId}`)
        this.customer = data
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    async getAvailableOwners () {
      try {
        //@TODO: @randa, pretty sure the customer list will work for process steps and projects but double checking
        const {data} = await getRequest(`/project/owners`)
        this.availableOwners = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving List of Owners')
      }
    },
    updateOwner: async function () {
      this.displayChangeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/project/${this.projectId}/owner`, this.project.owner)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style scoped lang="scss">
#project-admin-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.project-header {
  border-bottom: solid 1px #EAEAF4
}
.project-title {
  font-size: 20px;
}
.project-subtitle {
  font-size: 15px;
}
</style>
