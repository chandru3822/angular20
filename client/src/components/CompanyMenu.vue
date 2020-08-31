<template id="account-menu">
  <v-menu data-app left
          offset-y
          v-model="menuOpen"
          class="account-menu"
          :close-on-content-click="false">
    <template v-slot:activator="{ on }">
      <v-btn class="account-menu-button"
             :color="headerColor"
             dark
             v-on="on"
      >
        Company
        <v-icon>mdi-chevron-down</v-icon>
      </v-btn>
    </template>
    <div>
      <v-list>
        <v-list-item v-for="(item, index) in filterBy(menuItems, true, 'show')" :key="index" @click="menuOpen = false" :to="item.path">
          <v-list-item-title>{{item.title}}</v-list-item-title>
          <v-list-item-action class="account-menu-icon">
            <v-icon>{{item.icon}}</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </div>
  </v-menu>
</template>

<script>
  import constants from '@/helpers/constants'
  import Vue2Filters from "vue2-filters"

  const { VUE_APP_ENV } = process.env

  export default {
    name: 'CompanyMenu',
    mixins: [Vue2Filters.mixin],
    props: {},
    watch: {},
    data () {
      return {
        constants,
        loadComplete: false,
        userId: this.$store.state.user.details.id,
        headerColor: VUE_APP_ENV === 'local' ? 'blue' :
                     VUE_APP_ENV === 'dev' || VUE_APP_ENV === 'stage' ? 'orange' :
                     VUE_APP_ENV === 'uat' ? 'blue' : 'primaryCustom',
        menuOpen: false,
        highestCompanyId: this.$store.state.user.details.highestCompanyId,
      }
    },
    computed: {
      menuItems() {
        return [
          {
            path: '/ahj',
            title: 'AHJ Database',
            show: this.$store.getters.userHasFeature('AHJ_DATABASE')
          }, {
            path: '/closerDashboard',
            title: 'Closer Dashboard',
            show: this.$store.getters.userHasFeature('CLOSER_DASHBOARD')
          }, {
            path: '/installation-agreements/request',
            title: 'Installation Agreements',
            show: this.$store.getters.userHasFeature('INSTALLATION_AGREEMENT')
          }, {
            path: '/setterDashboard',
            title: 'Setter Dashboard',
            show: this.$store.getters.userHasFeature('SETTER_DASHBOARD')
          }, {
            path: '/commissionManagement/closers',
            title: 'Commissions',
            show: this.$store.getters.userHasFeature('COMMISSIONS')
          }, {
            path: '/finances/rebate/viewPayments',
            title: 'Rebates',
            show: this.$store.getters.userHasFeature('REBATES')
          }, {
            path: '/proposal',
            title: 'Proposals',
            show: this.$store.getters.userHasFeature('REBATES')
          },

        ]
      }
    },
    created () {},
    methods: {
      changeRoute (path) {
        this.$router.push({ name: path })
      },
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
