<template>
<v-row>
  <v-col cols="12" class="pa-0">
    <v-card flat v-for="ps in steps"
            :class="{'active-ps': ppsId === ps.projectProcessStepId}"
            class="active-ps-button"
            @click="goToPath(`/project/${projectId}/processStep/${ps.projectProcessStepId}?processStepId=${ps.processStepId}&contactId=${contactId}`)">
      {{ ps.processStepName }}
      <span :class="getStatusClass(ps.processStepStatusTypeId)">{{ps.processStepStatusType}}</span>
      <div class="ps-owner" v-if="ps && ps.owner && ps.owner.fullName">{{ ps.owner.fullName }}</div>
      <div style="font-weight: 600; color: rebeccapurple;">({{ ps.projectProcessStepId }})</div>
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
  computed: {
    ppsId () {
      return parseInt(this.$route.params.processStepId)
    }
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
.active-ps {
  background-color: #C4C4C4;
}

.active-ps-button {
  border: solid 1px #C4C4C4;
  padding: 10px;
  font-size: 14px;
  margin-bottom: 10px;
}

.ps-owner {
  font-size: 12px;
  color: #9E9C9C;
}
</style>
