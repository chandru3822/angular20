<template>
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

        <v-col v-else>
          <ProjectActiveProcessStep :steps="processSteps" :projectId="projectId"/>
        </v-col>
      </v-row>
    </v-col>
  </v-col>
</v-row>
</template>

<script>

import {getRequest, VUE_APP_FLOW_API} from '@/helpers/helpers'
import ProjectFieldGroup from '@/views/flow/project/ProjectFieldGroup'
import ProjectActiveProcessStep from '@/views/flow/project/ProjectActiveProcessStep'
import SpinnerInline from '@/components/SpinnerInline'

export default {
  name: 'ProjectOverview',
  components: {
    SpinnerInline,
    ProjectFieldGroup,
    ProjectActiveProcessStep
  },
  data () {
    return {
      projectId: this.$route.params.projectId,
      companyId: this.$store.state.user.details.companyId,
      processSteps: [],
      customFieldGroups: [],
      isProcessStepsLoading: true,
      isFieldsLoading: true
    }
  },
  created () {
    this.getFieldGroups()
    this.getProcessSteps()
  },
  methods: {
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

</style>
