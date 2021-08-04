<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <h3>{{ objectType }}</h3>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
            <v-tabs>
              <v-tab :to="`/settings/objectType/${companyObjectTypeId}/customFieldGroups?objectType=${objectType}`">
                Custom Field Groups
              </v-tab>
              <v-tab :to="`/settings/objectType/${companyObjectTypeId}/attachments?objectType=${objectType}`">
                Attachment Types
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import constants from '@/helpers/constants'

export default {
  name: 'ObjectType',
  mixins: [Vue2Filters.mixin],
  props: {
    isProject: Boolean
  },
  watch: {
    // whenever objectTypeId changes, this function will run
    '$route.params.id': function (oldObjectTypeId, newObjectTypeId) {
      // reset the selected group when the object type changes
      this.companyObjectTypeId = this.$route.params.id
      this.objectType = this.$route.query.objectType
    }
  },
  data () {
    return {
      snackbar: {},
      constants,
      companyObjectTypeId: this.$route.params.id,
      objectType: this.$route.query.objectType
    }
  },

  created () {},
  methods: {}
}
</script>
