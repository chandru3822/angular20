<template>
  <v-container class="pa-0">
    <v-row>
    <v-col class="group" cols="12" md="6" v-for="n in numberOfCols">
        <AhjCustomFields v-for="group in getGroupsByCol(n)" :group = group
                         :user-can-edit="userCanEdit"
                         :expanded-all="expandedAll"
                         :callback="(field) => callback(field)"
                         :hardcoded-docs="hardcodedDocs"
                         :source-id="sourceId"
                         @toggle-collapse-expand="$emit('toggle-collapse-expand')"
                         class="my-2"
        ></AhjCustomFields>
    </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjConstants";
import AhjCustomFields from "@/views/blueraven/ahj/components/AhjCustomFields";

export default {
  name: "TwoColumnMasonry",
  components: {AhjCustomFields},
  props: {
    customFieldGroups: Array,
    userCanEdit: Boolean,
    expandedAll: CollapseExpandEnum,
    hardcodedDocs: Map,
    sourceId: Number,
    callback:Function
  },
  data:() => ({
    CollapseExpandEnum,

  }),
  computed: {
    numberOfCols(){
      if(this.$vuetify.breakpoint.mdAndUp) {
        return 2
      }
      return 1
    }

  },
  methods: {
    getGroupsByCol(colNumber) {
      if (this.$vuetify.breakpoint.mdAndUp) {
        return this.customFieldGroups.filter(cfg => cfg.groupColumnOrder === colNumber)
            .sort((cfg1, cfg2) => {
              if (cfg1.groupOrder < cfg2.groupOrder) {
                return -1
              }
              if (cfg1.groupOrder > cfg2.groupOrder) {
                return 1
              }
              return 0
            })
      }
      //if smaller than md, we only have one column, so we just need to make sure things are in the right order
      return this.customFieldGroups.sort((cfg1, cfg2) => {
        if(cfg1.groupColumnOrder > cfg2.groupColumnOrder) {
          return 1
        }
        if (cfg1.groupColumnOrder <= cfg2.groupColumnOrder){
          if (cfg1.groupOrder < cfg2.groupOrder) {
            return -1
          }
          if (cfg1.groupOrder > cfg2.groupOrder) {
            return 1
          }
          return 0
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
