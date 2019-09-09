<template>
<v-row>
  <v-col>
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

        <v-row no-gutters>
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
</template>

<script>
export default {
  name: 'ProjectActiveProcessStep',
  props: {
    step: Object
  }
}
</script>


<style scoped lang="scss">

</style>
