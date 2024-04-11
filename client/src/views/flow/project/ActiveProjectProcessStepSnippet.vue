<template>
  <v-row>
    <v-col cols="12" class="pa-0">
      <div class="pa-0 ma-0" v-for="ps in steps">
        <router-link :to="`/project/${projectId}/processStep/${ps.projectProcessStepId}`" class="no-text-decoration default-text-color">
          <v-card flat
                  :class="{'active-ps': ppsId === ps.projectProcessStepId}"
                  class="active-ps-button albatross-body-1">
              {{ ps.processStepName }}
            <span :class="getStatusClass(ps.processStepStatusTypeId)">
                {{ps.processStepStatusType}}
            </span>
            <div class="ps-owner albatross-body-2" v-if="ps && ps.owner && ps.owner.fullName">
                {{ ps.owner.fullName }}
            </div>
            <div class="albatross-body-3 grey--text text--darken-2"
                 v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN') ||
                     userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')">
              {{ ps.projectProcessStepId }}
            </div>
          </v-card>
        </router-link>
      </div>
    </v-col>
  </v-row>
</template>

<script setup>
import {getStatusClass} from '@/services/processStepStatusTypeService'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  projectId: Number,
  steps: Array,
  contactId: Number
})
const { projectId, steps, contactId } = toRefs(props)

const ppsId = computed(() => {
  return parseInt(route.params.processStepId)
})

onMounted(() => {
  // console.log(steps)
})
const goToPath = (path) => {
  router.push(path)
}
</script>


<style scoped lang="scss">
//removes the blue-ish effect after you click one of these
.active-ps:focus::before {
  opacity: 0;
}

.active-ps {
  background-color: var(--v-primary-lighten9) ;
}

.active-ps-button {
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin-bottom: 10px;
}

.ps-owner {
  color: var(--v-grey-darken2);
}
</style>
