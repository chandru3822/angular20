<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-btn text class="pl-1 pr-2" :to="'/settings/events'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>
        <v-toolbar flat class="app-toolbar">
          <span class="page-title" v-if="!editName">{{ event.eventName }}</span>
          <v-text-field v-else color="primary"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        v-model="event.eventName"
                        hide-details
                        label="Event Name"></v-text-field>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="userCanEdit && !editName" class="" @click="[oldName = event.eventName, editName = !editName]">
              <v-icon>edit</v-icon>
            </v-btn>
            <v-btn text class="" v-else-if="userCanEdit" @click="saveEventName()">
              <v-icon>save</v-icon>
            </v-btn>
            <v-btn text  v-if="userCanEdit && editName" class="" @click="[event.eventName = oldName, editName = !editName]">
              cancel
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-tabs class="tabs-bar">
          <v-tab :to="`/settings/event/${eventId}/components`">
            Components
          </v-tab>
          <v-tab :to="`/settings/event/${eventId}/customFieldGroups`">
            Custom Field Groups
          </v-tab>
        </v-tabs>
        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'

import constants from '@/helpers/constants'
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getSnackbar, putRequest} from "@/helpers/helpers";

export default {
  name: 'Event',
  mixins: [Vue2Filters.mixin],

  data () {
    return {
      snackbar: {},
      constants,
      editName: false,
      oldName: null,
      event: {},
      eventId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
    }
  },
  computed: {
  },
  async created () {
    await this.getEvent()
  },
  methods: {
    async getEvent () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/event/${this.eventId}`)
        this.event = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveEventName() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/event`, this.event)
        this.editName = false
        this.snackbar = getSnackbar('SUCCESS', 'Event Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}

.page-title {
  font-size: 18px;
  font-weight: 200;
}

.tabs-bar {
  top: -12px;
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
