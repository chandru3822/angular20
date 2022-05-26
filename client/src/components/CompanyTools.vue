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
        <v-list-item v-for="(item, index) in companyTools"
                     :class="{'pa-0': item.featureCode === 'TOURNAMENTS'}"
                     :key="index" @click="closeMenu(item)" :to="item.featurePath">
          <v-list-item-title v-if="item.featureCode !== 'TOURNAMENTS'">{{item.featureName}}</v-list-item-title>

          <v-list-group
            v-else
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
  const { VUE_APP_ENV } = process.env

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
        userId: this.$store.state.user.details.id,
        headerColor: VUE_APP_ENV === 'local' ? constants.LOCAL_COLOR :
                     VUE_APP_ENV === 'dev' || VUE_APP_ENV === 'stage' ?  constants.STAGE_COLOR :
                     VUE_APP_ENV === 'flux' ? constants.FLUX_COLOR :
                     VUE_APP_ENV === 'uat' ? constants.UAT_COLOR : constants.PROD_COLOR,
        menuOpen: false,
        highestCompanyId: this.$store.state.user.details.highestCompanyId,
      }
    },
    computed: {},
    created () {},
    methods: {
      closeMenu(item) {
        if(item.featureCode !== 'TOURNAMENTS') {
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
  .account-menu-button{
    text-transform: capitalize;
    box-shadow: none !important;
    -webkit-box-shadow: none !important;
    border: none !important;
  }
</style>
