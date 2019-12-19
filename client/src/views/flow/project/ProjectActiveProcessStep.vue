<template>
<v-row>
  <v-col cols="12">
    <v-card>
      <v-card-text style="padding: 0">
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

        <v-row no-gutters v-for="step in steps" :key="step.projectProcessStepId">
          <v-col cols="1" >
            <router-link :to="`/project/${projectId}/processStep/${step.projectProcessStepId}?processStepId=${step.processStepId}`">{{ step.projectProcessStepId }}</router-link>
          </v-col>
          <v-col cols="3">{{ step.processStepName }}</v-col>
<!--          <v-col cols="3">{{ step.owner }}</v-col>-->
<!--         todo: @humes judson didn't want to see "Cameron Carlson" assigned to all the active process steps. so i hid this line ^^ -->
          <v-col cols="3"></v-col>
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
  name: 'ProjectActiveProcessStep',
  props: {
    projectId: Number,
    steps: Array
  }
}
</script>


<style scoped lang="scss">

</style>
