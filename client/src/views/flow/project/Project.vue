<template>

<!-- @TODO: Move inline css to classes -->

<v-container id="project-container">
  <v-row>
    <v-col cols="12">
      <v-sheet color="#fff" class="elevation-2 pa-4 br-10">
        <v-row>

          <v-col cols="4" class="text-left">
            <h1>Joe Customer</h1>
            <h3>123 main Street - Denver, CO</h3>
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
    <v-col cols="6">
      <v-row>
        <v-col cols="12">
          <h3 class="text-left">Summary</h3>
        </v-col>
      </v-row>

      <v-row>
        <v-col cols="12">
          <v-card>

            <Spinner
              v-if="isFieldsLoading"
              size="20"
              color="primary"
            />

            <v-row
              v-else
              class="text-left"
              style="border-bottom: 1px solid gray;"
              no-gutters
              v-for="field in fields"
              :key="field.customFieldId"
            >
              <v-col cols="4" class="font-weight-bold">{{ field.fieldName }}</v-col>
              <v-col cols="8">{{ field.dateValue }}</v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-row>
    </v-col>
  </v-row>

  <v-row>
    <v-col cols="6">
      <v-row>
        <v-col cols="12">
          <h3 class="text-left">Active Process Steps</h3>
        </v-col>
      </v-row>

      <v-row>
        <v-col cols="12">
          <v-card>

            <Spinner
              v-if="isProcessStepsLoading"
              size="20"
              color="primary"
            />

            <v-card-text v-else style="padding: 0">
              <v-row
                class="font-weight-bold"
                no-gutters
                style="border-bottom: 1px solid gray;"
              >
                <v-col cols="1">ID</v-col>
                <v-col cols="3">Type</v-col>
                <v-col cols="3">Owner</v-col>
                <v-col cols="3">Last Activity</v-col>
                <v-col cols="2">Status</v-col>
              </v-row>

              <v-row
                no-gutters
                v-for="step in processSteps"
                :key="step.projectProcessStepId"
              >
                <v-col cols="1">{{ step.projectProcessStepId }}</v-col>
                <v-col cols="3">{{ step.processStepName }}</v-col>
                <v-col cols="3">{{ step.owner }}</v-col>
                <v-col cols="3">{{ step.lastUpdated }}</v-col>
                <v-col cols="2">{{ step.processStepStatusType }}</v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</v-container>
</template>

<script>

import {getRequest} from '@/helpers/helpers'
import Spinner from '@/components/Spinner'
import UserCard from '@/components/UserCard'

export default {
  name: 'Project',
  components: {
    Spinner,
    UserCard
  },
  data () {
    return {
      companyId: this.$store.state.user.details.companyId,
      projectId: 168406,
      processSteps: [],
      fields: [],
      isProcessStepsLoading: true,
      isFieldsLoading: true
    }
  },
  created () {
    this.getFields()
    this.getProcessSteps()
  },
  methods: {
    getProcessSteps: async function () {
      try {
       const {data: steps} = await getRequest(`/api/v1/flow/${this.companyId}/project/${this.projectId}/processSteps`)
       this.processSteps = steps
     } catch (e) {
       console.error('*** ERROR ***', e)
     } finally {
       this.isProcessStepsLoading = false
     }
    },
    getFields: async function () {
      try {
        const {data: fields} = await getRequest(`/api/v1/flow/${this.companyId}/project/${this.projectId}/fields`)
        this.fields = fields
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

