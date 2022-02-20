<template>
<v-row>
  <v-col cols="12" class="pa-0">
    <v-card flat v-for="ps in steps"
            :class="{'active-ps': ppsId === ps.projectProcessStepId}"
            class="active-ps-button albatross-body-1"
            @click="goToPath(`/project/${projectId}/processStep/${ps.projectProcessStepId}?processStepId=${ps.processStepId}&contactId=${contactId}`)">
      {{ ps.processStepName }}
      <span :class="getStatusClass(ps.processStepStatusTypeId)">{{ps.processStepStatusType}}</span>
      <div class="ps-owner albatross-body-2" v-if="ps && ps.owner && ps.owner.fullName">{{ ps.owner.fullName }}</div>
      <div class="albatross-body-3"
           v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN') ||
                 $store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')">
        {{ ps.projectProcessStepId }}
      </div>
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
      // this.$store.commit(ProjectMutations.RESET_PROJECT_STATE)
      this.$router.push(path)
    },
  }
}
</script>


<style scoped lang="scss">
//removes the blue-ish effect after you click one of these
.active-ps:focus::before {
  opacity: 0;
}

.active-ps {
  background-color: #EEEEEE;
}

.active-ps-button {
  border: solid 1px #C4C4C4;
  padding: 10px;
  margin-bottom: 10px;
}

.ps-owner {
  color: #9E9C9C;
}
</style>
