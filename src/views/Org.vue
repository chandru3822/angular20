<template>
<v-container fluid v-if="!loading">
  <v-flex xs12 text-xs-left>
    <v-btn
      dark
      color="secondaryButton"
      class="app-button"
      @click="$router.back()"
    >Back</v-btn>
  </v-flex>
  <v-divider></v-divider>
  <v-form>
    <v-container>
      <v-layout row wrap align-start justify-space-between>
        <v-flex xs12 sm6>
          <v-text-field
            tabindex=1
            label="Name"
            v-model="org.orgName"
            :rules="form.rules"
          ></v-text-field>
        </v-flex>

        <v-flex xs12 sm6>
          <v-select
            tabindex=2
            :items="orgTypes"
            item-value="id"
            item-text="orgType"
            :disabled="mode === FORM_MODE.EDIT && org.type && org.type.id !== null"
            label="Type"
            v-model="org.type"
            :rules="form.rules"
            return-object
            @input="updateFields"
          ></v-select>
        </v-flex>

        <v-flex xs12 sm6>
          <v-select
            tabindex=3
            :items="parents"
            item-value="id"
            item-text="name"
            label="Parent"
            v-model="org.parent"
            :rules="form.rules"
            return-object
          ></v-select>
        </v-flex>

        <v-flex xs12 sm6 v-if="showSalesAreaSelector">
          <v-select
            tabindex=4
            :items="salesAreas"
            item-value="id"
            item-text="area"
            label="Sales Area"
            v-model="org.salesArea"
            return-object
            @input="updateFields"
          ></v-select>
        </v-flex>

        <v-flex xs12 sm6>
          <v-checkbox
            tabindex=5
            primary
            hide-details
            :disabled="mode === FORM_MODE.ADD"
            label="Active"
            v-model="org.active"
            ></v-checkbox>
        </v-flex>

        <v-flex xs12 sm6 v-if="showMetroAreaSelector">
          <v-select
            :items="activeMetroAreas"
            item-value="id"
            item-text="metroArea"
            label="Metro Areas"
            multiple
            return-object
            v-model="org.metroAreas"
          ></v-select>
        </v-flex>

        <v-flex xs12 sm6>
          <v-select
            :items="calendars"
            item-value="id"
            item-text="name"
            label="Calendar"
            v-model="org.calendarOid"
          ></v-select>
        </v-flex>

<!--        @TODO: This hardcoded value is evil and needs to die (pulled logic from the old crap, probably ties into the `updateType` function) -->
        <v-flex xs12 sm6 v-if="org.type && org.type.id === 2">
          <v-text-field
            label="Originator ID"
            v-model="org.originatorId"
          ></v-text-field>
        </v-flex>

        <v-flex xs12 sm6 v-if="org.type && org.type.showColorPicker">
<!--          @TODO: Implement a color picker -->
          color picker goes here
        </v-flex>

        <v-flex xs12 text-xs-right>
          <v-btn
            dark
            class="app-button"
            color="primaryButton"
            @click="submit"
          >Submit</v-btn>
        </v-flex>
      </v-layout>
    </v-container>
  </v-form>
</v-container>
</template>

<script>
import axios from 'axios'
import {mapState} from 'vuex'
import {AppMutations} from '@/stores/AppStore'

const {VUE_APP_BASE_API} = process.env

const FORM_MODE = {
  EDIT: 'edit',
  ADD: 'add'
}
export default {
  name: 'Org',
  props: ['orgId'],
  data () {
    return {
      FORM_MODE,
      orgLoading: false,
      generalDataLoading: false,
      org: {},
      orgTypes: [],
      salesAreas: [],
      activeMetroAreas: [],
      activeSalesMetroAreas: [],
      birdeyeLocations: [],
      calendars: [],
      resourceCalendars: [],
      parents: [],
      form: {
        rules: [
          val => !!val || 'Field is required'
        ]
      }
    }
  },
  computed: {
    mode () {
      return (this.orgId) ? FORM_MODE.EDIT : FORM_MODE.ADD
    },
    showSalesAreaSelector () {
      return this.org.type && this.org.type.showSalesArea
    },
    showMetroAreaSelector () {
      return this.org.salesArea && this.org.salesArea.id && this.org.type && this.org.type.id === 8
    },
    showSalesMetroAreaSelector () {
      return this.org.salesArea && this.org.salesArea.id && this.org.type && [3, 5].includes(this.org.type.id)
    },
    showBirdeyeSelector () {
      return this.org.type && [6, 11, 14].includes(this.org.type.id)
    },
    ...mapState({
      loading: state => state.app.loading
    })
  },
  methods: {
    async fetchOrg () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/orgs/${this.orgId}`)
      return data
    },
    async fetchOrgTypes () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/orgs/types`)
      return data
    },
    async fetchPotentialParents () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/orgs/parents/${this.org.type.orgParentTypeId}`)
      return data
    },
    async fetchSalesAreas () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/salesAreas`)
      return data
    },
    async fetchActiveMetroAreas () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/metroAreas/active/${this.org.salesArea.id}`)
      return data
    },
    async fetchActiveSalesMetroAreas () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/salesMetroAreas/active/${this.org.salesArea.id}`)
      return data
    },
    async fetchBirdeyeLocations () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/birdeyeLocations`)
      return data
    },
    async fetchCalanders () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/calendars`)
      return data
    },
    async fetchResourceCalendars () {
      const {data} = await axios.get(`${VUE_APP_BASE_API}/calendars/resource`)
      return data
    },
    async submit () {
      const {status} = await axios.post(`${VUE_APP_BASE_API}/orgs`, this.org)
      if (status === 204) {
        this.$router.push({name: 'orgs'})
      }
    },
    async updateFields () {
      this.parents = await this.fetchPotentialParents()

      // @TODO: Clear selected salesArea, metroAreas, and salesMetroAreas depending on if the selected type allow/disallows them

      // @TODO: These hardcoded ID's are being pulled from the old crap so I can more easily replicate functionality. But they need to die a horrible death
      switch (this.org.type.id) {
        case 3:
          if (this.org.salesArea && this.org.salesArea.id) {
            this.activeSalesMetroAreas = await this.fetchActiveSalesMetroAreas()
          }
          break
        case 5:
          if (this.org.salesArea && this.org.salesArea.id) {
            this.activeSalesMetroAreas = await this.fetchActiveSalesMetroAreas()
          }
          break
        case 8:
          if (this.org.salesArea && this.org.salesArea.id) {
            this.activeMetroAreas = await this.fetchActiveMetroAreas()
          }
          break
        case 6:
        case 11:
        case 14:
          // @TODO: hookup fetching birdeye locations. Will need backend integration...
          // this.birdeyeLocations = await this.fetchBirdeyeLocations()
      }
    }
  },
  async created () {

    // @TODO: Since most of this data is already fetch on the Orgs screen, this could potentially be fetched/saved to/from the store to reduce extra http requests
    // Execute requests in parallel (except for the parents dependency) and mark the app as not loading only when all are done
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.generalDataLoading = true
    Promise.all([
      this.fetchOrgTypes(),
      this.fetchSalesAreas(),
      this.fetchCalanders(),
      this.fetchResourceCalendars()
    ]).then(async ([orgTypes, salesAreas, calendars, resourceCalendars]) => {
      this.orgTypes = orgTypes
      this.salesAreas = salesAreas
      this.calendars = calendars
      this.resourceCalendars = resourceCalendars
      this.generalDataLoading = false
      if (!this.orgLoading) {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    })

    if (this.mode === FORM_MODE.EDIT) {
      this.orgLoading = true
      this.org = await this.fetchOrg()
      this.parents = await this.fetchPotentialParents()
      this.orgLoading = false
      if (!this.generalDataLoading) {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    } else {
      this.org.active = true
    }
  }
}
</script>

<style scoped lang="scss">

</style>
