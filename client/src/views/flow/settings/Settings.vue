<template>
  <v-container>
    <v-row>
      <v-col cols="3" class="text-left">
        <v-card class="px-5 py-2">
          <v-list dense>
            <template v-for="(item, index) in items">
              <h3 v-if="item.header">{{item.header}}</h3>

              <v-list-item
                  v-else
                  :key="item.title"
                  :to="item.path"
              >
                <v-list-item-content>
                  <v-list-item-title>{{item.title}}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <v-list-item dense v-for="o in filterBy(objectTypes, 1, 'flowTypeId')" :index="o.id"
                         :to="{ path: `/settings/customFieldGroup/${o.id}`}"
                         :class="{'shaded-row': $route.path === `/settings/customFieldGroup/${o.id}`}">
              <v-list-item-content>
                <v-list-item-title>{{o.objectType}}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-card>
      </v-col>
      <v-col cols="9" class="pa-4">
        <v-sheet color="#fff" class="elevation-2 text-xs-left">
          <router-view/>
        </v-sheet>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import Vue2Filters from 'vue2-filters'
import { getRequest, getSnackbar } from '@/helpers/helpers'

export default {
  name: 'Settings',
  mixins: [Vue2Filters.mixin],
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      objectTypes: [],
      companyId: this.$store.state.user.details.companyId,
      items: [
        {
          header: 'Preferences'
        }, {
          path: '/settings/userProfile',
          title: 'User Profile',
        }, {
          path: '',
          title: 'Account',
        }, {
          header: 'Custom Components'
        }, {
          path: '/settings/customFields',
          title: 'Custom Fields',
        }, {
          path: '/settings/attachments',
          title: 'Attachments',
        }, {
          path: '/settings/links',
          title: 'Links',
        }, {
          path: '/settings/orgTypes',
          title: 'Organization Types',
        }, {
          header: 'Processes'
        }, {
          path: '/settings/processes',
          title: 'Processes',
        }, {
          path: '/settings/processSteps',
          title: 'Process Steps',
        }, {
          path: '/settings/functions',
          title: 'Funtions',
        }, {
          path: '/settings/statuses',
          title: 'Statuses',
        }, {
          header: 'Objects'
        },
      ]
    }
  },
  computed: {
  },
  methods: {
    async getCustomFieldObjectTypes () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customField/getCustomFieldObjectTypes`)
        this.objectTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  },
  created () {
    this.getCustomFieldObjectTypes()
  }
}
</script>

<style scoped lang="scss">
testing {
  background-color: red;
}
a {
  text-decoration: none;
}
</style>
