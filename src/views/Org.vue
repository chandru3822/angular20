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
      <v-layout row wrap align-start>
        <v-flex xs12 sm6 md4>
          <v-text-field
            tabindex=1
            label="Name"
            v-model="org.orgName"
            :rules="form.rules"
          ></v-text-field>
        </v-flex>

        <v-flex xs12 sm6 md4>
          <v-select
            tabindex=2
            :items="orgTypes"
            item-value="id"
            item-text="orgType"
            :disabled="disableTypeField"
            label="Type"
            v-model="org.type"
            :rules="form.rules"
            return-object
            @input="updateFields"
          ></v-select>
        </v-flex>

        <v-flex xs12 sm6 md4>
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

        <v-flex xs12 sm6 md4 v-if="showSalesAreaSelector">
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

        <v-flex xs12 sm6 md4>
          <v-checkbox
            tabindex=5
            primary
            hide-details
            :disabled="disableActiveField"
            label="Active"
            v-model="org.active"
            ></v-checkbox>
        </v-flex>

        <v-flex xs12 sm6 md4 v-if="showMetroAreaSelector">
          <v-select
            :items="activeMetroAreas"
            item-value="id"
            item-text="metroArea"
            label="Metro Areas"
            multiple
            return-object
            v-model="org.metroAreas"
          >
            <template #selection="{item, index}">
              <v-chip v-if="index === 0 && org.metroAreas.length < 2">
                <span>{{ item.metroArea }}</span>
              </v-chip>
              <span
                v-if="index === 1 && org.metroAreas.length >= 2"
                class="primary--text caption"
              >{{ org.metroAreas.length }} selected</span>
            </template>
          </v-select>
        </v-flex>

        <v-flex xs12 sm6 md4 v-if="showSalesMetroAreaSelector">
          <v-select
            :items="activeSalesMetroAreas"
            item-value="id"
            item-text="salesMetroArea"
            label="Sales Metro Area"
            return-object
            v-model="org.salesMetroArea"
          ></v-select>
        </v-flex>

        <v-flex xs12 sm6 md4>
          <v-select
            :items="calendars"
            item-value="id"
            item-text="name"
            label="Calendar"
            v-model="org.calendarOid"
          ></v-select>
        </v-flex>

        <v-flex xs12 sm6 md4 v-if="showOriginatorSelector">
          <v-text-field
            label="Originator ID"
            v-model="org.originatorId"
          ></v-text-field>
        </v-flex>

        <v-flex xs12 sm6 md4 v-if="showColorPicker">
          <v-input label="Color">
            <v-menu
              top
              offset-y
              :max-height="'200px'"
              :max-width="'240px'"
            >
              <template #activator="{on}">
                <v-btn
                  outline
                  color="#C0C0C0"
                  class="color-option"
                  :style="{'background-color': `${org.color} !important`}"
                  v-on="on"
                ></v-btn>
              </template>
              <v-card>
                <v-layout row wrap>
                  <v-flex
                    v-for="color in colors"
                    :key="color"
                    xs2
                    ma-1
                    class="color-option"
                    :style="{'background-color': color}"
                    @click="org.color = color"
                  ></v-flex>
                </v-layout>
              </v-card>
            </v-menu>
          </v-input>
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
import {mapState} from 'vuex'
import {AppMutations} from '@/stores/AppStore'
import GOOGLE_CALENDARS from '@/graphql/GoogleCalendars.gql'
import RESOURCE_CALENDARS from '@/graphql/ResourceCalendars.gql'
import SALES_AREAS from '@/graphql/SalesAreas.gql'
import ACTIVE_METRO_AREAS from '@/graphql/ActiveMetroAreas.gql'
import ACTIVE_SALES_METRO_AREAS from '@/graphql/ActiveSalesMetroAreas.gql'
import ORG_TYPES from '@/graphql/OrgTypes.gql'
import ORG from '@/graphql/Org.gql'
import SAVE_ORG from '@/graphql/SaveOrg.gql'
import POTENTIAL_ORG_PARENTS_BY_ORG_TYPE_ID from '@/graphql/PotentialOrgParentsByOrgTypeId.gql'

const FORM_MODE = {
  EDIT: 'edit',
  ADD: 'add'
}
export default {
  name: 'Org',
  props: ['orgId'],
  data () {
    return {
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
      },
      colors: [
        '#330000', '#331900', '#333300', '#193300', '#003300', '#003319', '#003333', '#001933', '#000033', '#190033', '#330033', '#330019', '#000000',
        '#660000', '#663300', '#666600', '#336600', '#006600', '#006633', '#006666', '#003366', '#000066', '#330066', '#660066', '#660033', '#202020',
        '#990000', '#994C00', '#999900', '#4C9900', '#009900', '#00994C', '#009999', '#004C99', '#000099', '#4C0099', '#990099', '#99004C', '#404040',
        '#CC0000', '#CC6600', '#CCCC00', '#66CC00', '#00CC00', '#00CC66', '#00CCCC', '#0066CC', '#0000CC', '#6600CC', '#CC00CC', '#CC0066', '#606060',
        '#FF0000', '#FF8000', '#FFFF00', '#80FF00', '#00FF00', '#00FF80', '#00FFFF', '#0080FF', '#0000FF', '#7F00FF', '#FF00FF', '#FF007F', '#808080',
        '#FF3333', '#FF9933', '#FFFF33', '#99FF33', '#33FF33', '#33FF99', '#33FFFF', '#3399FF', '#3333FF', '#9933FF', '#FF33FF', '#FF3399', '#A0A0A0',
        '#FF6666', '#FFB266', '#FFFF66', '#B2FF66', '#66FF66', '#66FFB2', '#66FFFF', '#66B2FF', '#6666FF', '#B266FF', '#FF66FF', '#FF66B2', '#C0C0C0',
        '#FF9999', '#FFCC99', '#FFFF99', '#CCFF99', '#99FF99', '#99FFCC', '#99FFFF', '#99CCFF', '#9999FF', '#CC99FF', '#FF99FF', '#FF99CC', '#E0E0E0',
        '#FFCCCC', '#FFE5CC', '#FFFFCC', '#E5FFCC', '#CCFFCC', '#CCFFE5', '#CCFFFF', '#CCE5FF', '#CCCCFF', '#E5CCFF', '#FFCCFF', '#FFCCE5', '#FFFFFF'
      ]
    }
  },
  computed: {
    mode () {
      return (this.orgId) ? FORM_MODE.EDIT : FORM_MODE.ADD
    },
    showSalesAreaSelector () {
      return this.org.type && this.org.type.showSalesArea
    },
    // @TODO: These hardcoded values are evil and need to die (pulled logic from the old crap, probably ties into the `updateFields` function)
    showMetroAreaSelector () {
      return this.org.salesArea && this.org.salesArea.id && this.org.type && this.org.type.id === 8
    },
    showSalesMetroAreaSelector () {
      return this.org.salesArea && this.org.salesArea.id && this.org.type && [3, 5].includes(this.org.type.id)
    },
    showBirdeyeSelector () {
      return this.org.type && [6, 11, 14].includes(this.org.type.id)
    },
    showOriginatorSelector () {
      return this.org.type && this.org.type.id === 2
    },
    showColorPicker () {
      return this.org.type && this.org.type.showColorPicker === true
    },
    disableTypeField () {
      return this.mode === FORM_MODE.EDIT && this.org.type && this.org.type.id !== null
    },
    disableActiveField () {
      return this.mode === FORM_MODE.ADD
    },
    ...mapState({
      loading: state => state.app.loading
    })
  },
  methods: {
    async fetchOrg () {
      const { data } = await this.$apollo.query({
        query: ORG,
        fetchPolicy: 'no-cache',
        variables: {
          idStringInput: {
            id: this.orgId.toString()
          }
        },
        debounce: 500
      })
      const { org } = data
      return org
    },
    async fetchOrgTypes () {
      // const {data} = await getRequest('/orgs/types')
      // return data
      const { data } = await this.$apollo.query({
        query: ORG_TYPES,
        fetchPolicy: 'no-cache',
        variables: {},
        debounce: 500
      })
      const { orgTypes } = data
      return orgTypes
    },
    async fetchPotentialParents () {
      const { data } = await this.$apollo.query({
        query: POTENTIAL_ORG_PARENTS_BY_ORG_TYPE_ID,
        fetchPolicy: 'no-cache',
        variables: {
          idInput: {
            id: this.org.type.orgParentTypeId
          }
        },
        debounce: 500
      })
      const { potentialOrgParentsByOrgTypeId } = data
      return potentialOrgParentsByOrgTypeId
    },
    async fetchSalesAreas () {
      const { data } = await this.$apollo.query({
        query: SALES_AREAS,
        fetchPolicy: 'no-cache',
        variables: {},
        debounce: 500
      })
      const { salesAreas } = data
      return salesAreas
    },
    async fetchActiveMetroAreas () {
      const { data } = await this.$apollo.query({
        query: ACTIVE_METRO_AREAS,
        fetchPolicy: 'no-cache',
        variables: {
          idInput: {
            id: this.org.salesArea.id
          }
        },
        debounce: 500
      })
      const { activeMetroAreas } = data
      return activeMetroAreas
    },
    async fetchActiveSalesMetroAreas () {
      const { data } = await this.$apollo.query({
        query: ACTIVE_SALES_METRO_AREAS,
        fetchPolicy: 'no-cache',
        variables: {
          idInput: {
            id: this.org.salesArea.id
          }
        },
        debounce: 500
      })
      const { activeSalesMetroAreas } = data
      return activeSalesMetroAreas
    },
    async fetchBirdeyeLocations () {
      //todo: add this later
      // const {data} = await getRequest(`/birdeyeLocations`)
      // return data
    },
    async fetchCalendars () {
      // const {data} = await getRequest(`/calendars`)
      // return data
      const { data } = await this.$apollo.query({
        query: GOOGLE_CALENDARS,
        fetchPolicy: 'no-cache',
        variables: {},
        debounce: 500
      })
      const { googleCalendars } = data
      return googleCalendars
    },
    async fetchResourceCalendars () {
      // const {data} = await getRequest(`/calendars/resource`)
      // return data
      const { data } = await this.$apollo.query({
        query: RESOURCE_CALENDARS,
        fetchPolicy: 'no-cache',
        variables: {},
        debounce: 500
      })
      const { resourceCalendars } = data
      return resourceCalendars
    },
    async submit () {

      // Clear irrelevant/hidden fields before save
      if (!this.showSalesAreaSelector) {
        this.org.salesArea = {}
      }
      if (!this.showMetroAreaSelector) {
        this.org.metroAreas = []
      }
      if (!this.showSalesMetroAreaSelector) {
        this.org.salesMetroArea = {}
      }
      if (!this.showOriginatorSelector) {
        this.org.originatorId = null
      }

      //todo: i have no idea where these are coming from but they cause errors, need to fix
      delete this.org.parent.__typename
      delete this.org.type.__typename

      const { data } = await this.$apollo.mutate({
        mutation: SAVE_ORG,
        fetchPolicy: 'no-cache',
        variables: {
          orgInput: this.org
        },
        debounce: 500
      })
      const { saveOrg } = data
      this.$router.push({name: 'orgs'})
    },
    async updateFields () {
      this.parents = await this.fetchPotentialParents()

      // @TODO: These hardcoded ID's are being pulled from the old crap so I can more easily replicate functionality. But they need to die a horrible death
      switch (this.org.type.id) {
        case 3:
          if (this.org.salesArea && this.org.salesArea.id) {
            this.activeSalesMetroAreas = await this.fetchActiveSalesMetroAreas()
            this.org.salesMetroArea = {}
          }
          break
        case 5:
          if (this.org.salesArea && this.org.salesArea.id) {
            this.activeSalesMetroAreas = await this.fetchActiveSalesMetroAreas()
            this.org.salesMetroArea = {}
          }
          break
        case 8:
          if (this.org.salesArea && this.org.salesArea.id) {
            this.activeMetroAreas = await this.fetchActiveMetroAreas()
            this.org.metroAreas = []
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
      this.fetchCalendars(),
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
  .color-option {
    height: 30px;
    border: solid 1px #C0C0C0;
  }
</style>
