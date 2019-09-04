<template>

<!-- @TODO: Move inline css to classes -->

<v-container id="project-container">
  <v-row>
    <v-col cols="12">
      <v-sheet color="#fff" class="elevation-2 pa-4 br-10">
        <v-row>

          <v-col cols="7" class="text-left">
            <h1>Joe Customer</h1>
            <h3>123 main Street - Denver, CO</h3>
          </v-col>

          <v-col cols="1">
            Riley Burgess
          </v-col>

          <v-col cols="1">
            Mike Falls
          </v-col>

          <v-col cols="1">
            Associated Contact
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
            <v-row class="text-left" style="border-bottom: 1px solid gray;" no-gutters v-for="field in fields" :key="field">
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
            <v-row class="text-left" style="border-bottom: 1px solid gray;" no-gutters>
              <v-col cols="4" class="font-weight-bold">Originator</v-col>
              <v-col cols="8">Blue Raven Solar</v-col>
            </v-row>
            <v-row class="text-left" style="border-bottom: 1px solid gray;" no-gutters>
              <v-col cols="4" class="font-weight-bold">AHJ</v-col>
              <v-col cols="8">City of Denver</v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</v-container>
</template>

<script>

import {getRequest} from '@/helpers/helpers'

export default {
  name: 'Project',
  data () {
    return {
      companyId: this.$store.state.user.details.companyId,
      projectId: 45669,
      processSteps: [],
      fields: []
    }
  },
  async created () {
     const {data: steps} = await getRequest(`/api/v1/flow/${this.companyId}/project/${this.projectId}/processSteps`)
     this.processSteps = steps
     const {data: fields} = await getRequest(`/api/v1/flow/${this.companyId}/project/${this.projectId}/fields`)
     this.fields = fields
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
</style>

