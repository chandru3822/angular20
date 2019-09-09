<template>

<!-- @TODO: Move inline css to classes -->

<v-container id="project-container">
  <v-row>
    <v-col cols="12">
      <v-sheet color="#fff" class="elevation-2 pa-4 br-10">
        <v-row>

          <v-col cols="4" class="text-left">
            <h1>{{ customer.fullName}}</h1>
            <h3>{{ customer.street1 }} - {{ customer.city }}, {{ customer.state }}</h3>
          </v-col>

          <v-col cols="8">
            <v-row justify="end">
                <UserCard
                  name="Riley Burgess"
                  role="Setter"
                  location="Colorado"
                  imageUrl="https://s3.amazonaws.com/blueraven-apps/brLogo-57.png"
                  class="user-card"/>

                <UserCard
                  name="Mike Falls"
                  role="Closer"
                  location="Colorado"
                  imageUrl="https://s3.amazonaws.com/blueraven-apps/brLogo-57.png"
                  class="user-card"/>
            </v-row>
          </v-col>

        </v-row>
      </v-sheet>
    </v-col>
  </v-row>

  <v-row>
    <v-col cols="12" lg="6" xl="6">

      <v-col v-if="isFieldsLoading">
        <Spinner
          size="20"
          color="primary"
        />
      </v-col>

      <v-col v-else v-for="group in customFieldGroups" :key="group.customFieldId">
        <ProjectFieldGroup :group="group"/>
      </v-col>

      <v-col>
        <v-row>
          <v-col cols="12">
            <h3 class="text-left">Active Process Steps</h3>
          </v-col>


          <v-col v-if="isProcessStepsLoading">
            <SpinnerInline size="20" color="primary"/>
          </v-col>

          <v-col v-else v-for="step in processSteps" :key="step.projectProcessStepId">
            <ProjectActiveProcessStep :step="step"/>
          </v-col>
        </v-row>
      </v-col>
    </v-col>
  </v-row>
</v-container>
</template>

<script>

import {getRequest, VUE_APP_FLOW_API} from '@/helpers/helpers'
import SpinnerInline from '@/components/SpinnerInline'
import UserCard from '@/views/flow/components/UserCard'
import ProjectFieldGroup from '@/views/flow/project/ProjectFieldGroup'
import ProjectActiveProcessStep from '@/views/flow/project/ProjectActiveProcessStep'

export default {
  name: 'Project',
  components: {
    SpinnerInline,
    UserCard,
    ProjectFieldGroup,
    ProjectActiveProcessStep
  },
  data () {
    return {
      customerId: 9044,
      companyId: this.$store.state.user.details.companyId,
      projectId: 45669,
      customer: {},
      processSteps: [],
      customFieldGroups: [],
      isProcessStepsLoading: true,
      isFieldsLoading: true
    }
  },
  created () {
    this.getCustomer()
    this.getFieldGroups()
    this.getProcessSteps()
  },
  methods: {
    getCustomer: async function () {
      try {
        const{data} = await getRequest(`${VUE_APP_FLOW_API}/${this.companyId}/customer/${this.customerId}`)
        this.customer = data
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    getProcessSteps: async function () {
      try {
       const {data} = await getRequest(`${VUE_APP_FLOW_API}/${this.companyId}/project/${this.projectId}/processSteps`)
       this.processSteps = data
     } catch (e) {
       console.error('*** ERROR ***', e)
     } finally {
       this.isProcessStepsLoading = false
     }
    },
    getFieldGroups: async function () {
      try {
        const {data} = await getRequest(`${VUE_APP_FLOW_API}/${this.companyId}/customFieldValues/project/${this.projectId}`)
        this.customFieldGroups = data
      } catch (e) {
        console.error('*** ERROR ***', e)
      } finally {
        this.isFieldsLoading = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>
#project-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.user-card {
  margin-left: 10px;
  margin-right: 10px;
}
</style>

