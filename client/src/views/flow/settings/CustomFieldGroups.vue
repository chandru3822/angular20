<template>
  <v-layout row wrap>
    <v-flex xs-12>
      <h2>Custom Field Groups</h2>
      <span>* the color of this toolbar is a bug in vuetify being fixed in v2</span>
      <v-tabs
          background-color="#fff"
          color="primaryText"
          slider-color="#1F3C73"
      >
        <v-tab v-for="tab in tabs" :key="tab.id" @click="selectedGroup = tab">
          {{tab.objectType}}
        </v-tab>
      </v-tabs>
      <CustomFieldGroup v-if="selectedGroup && selectedGroup.id" :object-type-id="selectedGroup.id"></CustomFieldGroup>
    </v-flex>
  </v-layout>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
import draggable from 'vuedraggable'
import CustomFieldGroup from './components/CustomFieldGroup'

export default {
  name: 'CustomFields',
  components: {
    draggable,
    CustomFieldGroup
  },
  data () {
    return {
      companyId: this.$store.state.user.details.companyId,
      model: '',
      tabs: [],
      selectedGroup: {}
    }
  },
  computed: {
  },
  methods: {
    async getCustomFieldObjectTypes() {
      const {data} = await getRequest(`/api/v1/flow/customField/getCustomFieldObjectTypes`, { params: { companyId: this.companyId }})
      this.tabs = data
    }
  },
  async created () {
    this.getCustomFieldObjectTypes()
  }
}
</script>

<style scoped lang="scss">

</style>
