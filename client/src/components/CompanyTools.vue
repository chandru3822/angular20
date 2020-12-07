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
        <v-list-item v-for="(item, index) in companyTools" :key="index" @click="menuOpen = false" :to="item.featurePath">
          <v-list-item-title>{{item.featureName}}</v-list-item-title>
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
    name: 'CompanyTools',
    mixins: [Vue2Filters.mixin],
    props: {
        companyTools: Array
    },
    watch: {},
    data () {
      return {
        constants,
        loadComplete: false,
        userId: this.$store.state.user.details.id,
        headerColor: VUE_APP_ENV === 'local' ? 'pink' :
                     VUE_APP_ENV === 'dev' || VUE_APP_ENV === 'stage' ? 'orange' :
                     VUE_APP_ENV === 'uat' ? 'blue' : 'primaryCustom',
        menuOpen: false,
        highestCompanyId: this.$store.state.user.details.highestCompanyId,
      }
    },
    computed: {},
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
