<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-servicing-fots">
  <v-card class="mb-3">
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold"
                       title="Servicing FOT's"
      >Servicing FOT's</v-toolbar-title>
    </v-toolbar>
    <div class="padded-list"
         v-show="servicingFots.length > 0">
      <p v-for="(fot, index) in servicingFots"
         :key="index"
         class="my-0">
        <router-link v-if="fot.hierarchy !== null"
                     class="list-link"
                     :to="{ name: 'orgs', params: {orgFilter: fot.hierarchy.orgName} }"
        >{{ fot.hierarchy.orgName }}</router-link>
      </p>
    </div>
    <div class="empty-list"
         v-show="servicingFots.length < 1"
    >No Servicing FOT's found</div>
  </v-card>
</template>

<script>
  export default {
    name: "AhjServicingFot",
    props: {
      servicingFots: {
        type: Array,
        default: () => []
      }
    }
  }
</script>

<style scoped lang="scss">
  .list-link {
    font-size: 0.85em !important;
    text-decoration: none;
    &:hover {
      text-decoration: underline;
    }
  }
  .v-toolbar__title {
    font-size: 1em !important;
  }
  .padded-list {
    padding: 18px;
  }
  .empty-list {
    padding: 20px;
    font-size: 0.85em;
  }
</style>
