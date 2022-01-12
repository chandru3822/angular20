<template>
<v-row>
  <v-col cols="12" class="pt-0">
    <v-card flat v-for="ps in steps" class="active-ps-button"
            @click="goToPath(`/project/${projectId}/processStep/${ps.projectProcessStepId}?processStepId=${ps.processStepId}&contactId=${contactId}`)">
      {{ ps.processStepName }}
      <span :class="getStatusClass(ps.processStepStatusTypeId)">{{ps.processStepStatusType}}</span>
    </v-card>
  </v-col>
</v-row>
</template>

<script>
import {getStatusClass} from '@/services/processStepStatusTypeService'

export default {
  name: 'ActiveProjectProcessStepSnippet',
  props: {
    projectId: Number,
    steps: Array,
    contactId: Number
  },
  data () {
    return {
      getStatusClass
    }
  },
  methods: {
    goToPath(path) {
      this.$router.push(path)
    },
  }
}
</script>


<style scoped lang="scss">
.active-ps-button {
  border: solid 1px #C4C4C4;
  padding: 10px;
  font-size: 14px;
  margin-bottom: 10px;
}

</style>
