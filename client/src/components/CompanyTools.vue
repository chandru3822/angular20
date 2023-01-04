<template id="account-menu">
  <v-menu data-app left
          offset-y
          :max-height="`calc(100vh - 20px)`"
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <v-btn class="account-menu-button"
             :color="headerColor"
             dark
             v-on="on"
      >
        Tools
        <v-icon>mdi-chevron-down</v-icon>
      </v-btn>
    </template>
    <div>
      <v-list>
        <v-list-item v-for="(item, index) in mutableCompanyTools"
                     :class="{'pa-0': item.featureCode === 'TOURNAMENTS' || item.featureCode ==='DATABASE'}"
                     :key="index" @click="closeMenu(item)"
                     :to="item.featurePath">
          <v-list-item-title v-if="item.featureCode !== 'TOURNAMENTS' && item.featureCode !== 'DATABASE'">{{item.featureName}}</v-list-item-title>

          <v-list-group
            v-else-if="item.featureCode == 'TOURNAMENTS'"
            class="pa-0"
            :value="false"
            @click="loadBrsTournaments"
          >
            <template v-slot:activator>
                <v-list-item-title >{{item.featureName}}</v-list-item-title>
            </template>

            <v-list-item v-if="tourneysLoading">
              <v-list-item-title>
                <SpinnerInline :size="20" color="primary"/>
              </v-list-item-title>
            </v-list-item>

            <v-list-item v-if="!tourneysLoading && tournaments.length === 0">
              <v-list-item-title class="px-7">
                No Active Tournaments
              </v-list-item-title>
            </v-list-item>

            <v-list-item
              v-else-if="!tourneysLoading"
              v-for="(t, i) in tournaments"
              :key="i"
              class="px-7"
              @click="closeMenu(t)"
              :to="`/tournament/${t.id}`"
              link
            >
              <v-list-item-title>{{t.tournamentName}}</v-list-item-title>
            </v-list-item>
          </v-list-group>
          <v-list-group
            v-else
            class="pa-0"
            :value="false"
            @click="loadDatabaseOptions(index)"
            style="width: 100%"
          >
            <template v-slot:activator>
              <v-list-item-title >{{item.featureName}}</v-list-item-title>
            </template>


            <v-list-item
              v-for="(t, i) in databaseOptions"
              :key="i"
              class="px-7"
              @click="closeMenu(t)"
              :to="`${databasePaths[i]}`"
              link
            >
              <v-list-item-title>{{t}}</v-list-item-title>
            </v-list-item>
          </v-list-group>
      </v-list-item>
      </v-list>
    </div>
  </v-menu>
</template>

<script>
  import constants from '@/helpers/constants'
  import Vue2Filters from "vue2-filters"
  import SpinnerInline from '@/components/SpinnerInline'
  import { getRequest, getSnackbar } from '@/helpers/helpers'
  const { VITE_ENV } =  import.meta.env
  import { AppMutations } from '@/stores/AppStore'

  export default {
    name: 'CompanyTools',
    components: {
      SpinnerInline
    },
    mixins: [Vue2Filters.mixin],
    props: {
        companyTools: Array
    },
    watch: {},
    data () {
      return {
        constants,
        tournaments: [],
        tourneysLoading: false,
        loadComplete: false,
        mutableCompanyTools: this.companyTools,
        userId: this.$store.state.user.details.id,
        headerColor: VITE_ENV === 'local' ? constants.LOCAL_COLOR :
                     VITE_ENV === 'dev' || VITE_ENV === 'stage' ?  constants.STAGE_COLOR :
                     VITE_ENV === 'flux' ? constants.FLUX_COLOR :
                     VITE_ENV === 'uat' ? constants.UAT_COLOR : constants.PROD_COLOR,
        menuOpen: false,
        highestCompanyId: this.$store.state.user.details.highestCompanyId,
        databaseLoaded: false,
        databaseOptions: [],
        databasePaths: []
      }
    },
    computed: {},
    created () {
      this.filterForParents();
    },
    methods: {
      closeMenu(item) {
        if(item.featureCode !== 'TOURNAMENTS' && item.featureCode !== 'DATABASE') {
          this.menuOpen = false
        }
      },
      async loadBrsTournaments() {
        this.tourneysLoading = true
        try {
          const {data} = await getRequest('/tournament/active', 'blueraven')
          this.tournaments = data
          this.tourneysLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournaments')
          this.tourneysLoading = false
        }
      },

      async loadDatabaseOptions(index) {
        this.databaseOptions = this.mutableCompanyTools[index].childNames;
        this.databasePaths = this.mutableCompanyTools[index].childPaths;
      },

      async filterForParents() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        var filteredTools = this.companyTools.slice().reverse();
        var lastName = " ";
        this.companyTools.slice().reverse().forEach(
          x => {
            if (x.featureName == lastName) {
              filteredTools.splice(filteredTools.indexOf(x), 1);
            }
            lastName = x.featureName;
          }
      );
        this.mutableCompanyTools = filteredTools.reverse();
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  h3 {
    margin: 40px 0 0;
  }
  ul {
    list-style-type: none;
    padding: 0;
  }
  li {
    display: inline-block;
    margin: 0 10px;
  }

  .v-list .v-list-item--active{
    color:var(--v-anchor-base);
    background-color: var(--v-primary-lighten9);
  }
  .account-menu-button{
    text-transform: capitalize;
    box-shadow: none !important;
    -webkit-box-shadow: none !important;
    border: none !important;
  }
</style>
