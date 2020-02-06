<template>
<v-row>
  <v-col cols="12">
    <v-card>
      <v-card-text class="pa-0">
        <v-row class="header font-weight-bold py-3" no-gutters>
          <v-col cols="1">ID</v-col>
          <v-col cols="3">Type</v-col>
          <v-col cols="3">Owner</v-col>
          <v-col cols="3">Last Activity</v-col>
          <v-col cols="2">Status</v-col>
        </v-row>

        <v-row
          no-gutters
          v-for="step in steps"
          :key="step.projectProcessStepId"
          class="py-2"
        >
          <v-col cols="1" >
            <router-link :to="`/project/${projectId}/processStep/${step.projectProcessStepId}?processStepId=${step.processStepId}&customerId=${customerId}`">{{ step.projectProcessStepId }}</router-link>
          </v-col>
          <v-col>{{step.processStepName}}</v-col>
          <v-col cols="3">{{ step.owner }}</v-col>
          <v-col cols="3">{{ step.lastUpdated }}</v-col>
          <v-col cols="2">{{ step.processStepStatusType }}</v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </v-col>
</v-row>
</template>

<script>
export default {
  name: 'ActiveProjectProcessStepSnippet',
  props: {
    projectId: Number,
    steps: Array,
    customerId: Number
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
