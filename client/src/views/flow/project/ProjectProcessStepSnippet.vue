<template>
  <v-row>
    <v-col cols="12">
      <v-card>
        <v-card-text class="pa-0">
          <v-row class="header font-weight-bold py-1" no-gutters>
            <v-col cols="2">ID</v-col>
            <v-col cols="3">Name</v-col>
            <v-col cols="2">Owner</v-col>
            <v-col cols="2">Last Activity</v-col>
            <v-col cols="2">Status</v-col>
              <v-col cols="1">Primary</v-col>
          </v-row>

          <v-row
            no-gutters
            v-for="step in steps"
            :key="step.projectProcessStepId"
            class="py-0 align-center"
          >
            <v-col cols="2" >
              <router-link :to="`/project/${projectId}/processStep/${step.projectProcessStepId}?processStepId=${step.processStepId}&contactId=${contactId}`">{{ step.projectProcessStepId }}</router-link>
            </v-col>
            <v-col cols="3">{{ step.processStepName }}</v-col>
            <v-col cols="2">{{ step.owner && step.owner.fullName }}</v-col>
            <v-col cols="2">{{ step.lastUpdated }}</v-col>
            <v-col cols="2">{{ step.processStepStatusType }}</v-col>
              <v-col cols="1">
                  <v-checkbox
                      v-model="step.main"
                      :disabled="true"
                  />
              </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
  export default {
    name: 'ProjectProcessStepSnippet',
    props: {
      projectId: Number,
      steps: Array,
      contactId: Number
    }
  }
</script>

<style scoped lang="scss">

.header {
  background-color: #E6E6E9;
  color: #1F3C73;
  border-bottom: 1px solid #C7C7CC;
}
</style>
