<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-servicing-fots">
  <v-container>
    <div class="padded-list"
         v-show="servicingFots.length > 0">
      <p v-for="(fot, index) in servicingFots"
         :key="index"
         class="my-0">
        <router-link v-if="fot.hierarchy !== null && userStore.userHasFeature('ORGS')"
                     class="list-link"
                     :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}"
                     :to="{ name: 'orgs', params: {orgFilter: fot.hierarchy.orgName} }"
        >{{ fot.hierarchy.orgName }}</router-link>
        <span v-else>{{ fot.hierarchy.orgName }}</span>
      </p>
    </div>
    <div class="empty-list" v-show="servicingFots.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}"
    >No Servicing FOT's found</div>
  </v-container>
</template>

<script setup>
import { getCurrentInstance, toRefs } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy

const props = defineProps({
  servicingFots: {
    type: Array,
    default: () => []
  },
  isNested: {
    type: Boolean,
    default: false
  }
})

const { servicingFots, isNested } = toRefs(props)

</script>

<style scoped lang="scss">
.list-link {
  font-size: 0.85em !important;
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
}
.v-toolbar__title {
  font-size: 1em !important;
}
.padded-list {
  padding: 18px;
}
.empty-list {
  padding: 20px;
  font-size: 0.85em;
}
</style>
