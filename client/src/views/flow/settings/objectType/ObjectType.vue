<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" id="object-settings-toolbar">
          <h3>{{ objectType }}</h3>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="isMobile ? 'extension' : 'default'">
            <v-tabs class="tabs-bar" v-model="activeTab" id="object-settings-tabs">
              <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                     class="text-capitalize ma-0"
                     :style="{'margin-left': (index === 0 && $vuetify.breakpoint.smAndDown) ? '12px !important' : '0'}">
                {{ tab.label }}
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
  computed: {
    //this should not be so hard
    activeTab: {
      get: function() {
        return this.$route?.path?.includes('/objectType') ? `/settings/objectType/${this.companyObjectTypeId}/attachmentTypes?objectType=${this.objectType}` : null
      },
      set: function(val) {
        return val
      }
    },
    tabs() {
     return [
        {
          id: 1,
          label: 'Custom Field Groups',
          path: `/settings/objectType/${this.companyObjectTypeId}/customFieldGroups?objectType=${this.objectType}`,
        },
        {
          id: 2,
          label: 'Attachment Types',
          path: `/settings/objectType/${this.companyObjectTypeId}/attachmentTypes?objectType=${this.objectType}`,
        }
      ]
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    }
  },
  watch: {
    // whenever objectTypeId changes, this function will run
    '$route.params.id': function () {
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
<style lang="scss">
@media (max-width: 959px) {
  #object-settings-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #object-settings-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
  #object-settings-toolbar > div.v-toolbar__extension {
    padding-bottom: 0.75rem;
  }
}
</style>
