<template>
  <v-container class="pa-0">
    <v-row>
    <v-col class="group" cols="12" md="6">
        <AhjCustomFields v-for="group in firstColGroups" :group = group
                         :user-can-edit="userCanEdit"
                         :expanded-all="expandedAll"
                         :callback="(field) => updateDirtyValue(field)"
                         @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"
                         class="my-2"
        ></AhjCustomFields>
    </v-col>
    <v-col v-if="$vuetify.breakpoint.mdAndUp" class="group" cols="12" md="6">
        <AhjCustomFields v-for="group in secondColGroups" :group = group
                         :user-can-edit="userCanEdit"
                         :expanded-all="expandedAll"
                         :callback="(field) => callback(field)"
                         @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"
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
    callback:Function
  },
  data:() => ({
    CollapseExpandEnum,

  }),
  computed: {
    firstColGroups(){
      if(this.$vuetify.breakpoint.mdAndUp) {
        return this.customFieldGroups.filter((_,i) => i % 2 === 0)
      }
      return this.customFieldGroups
    },
    secondColGroups(){
      if(this.$vuetify.breakpoint.mdAndUp) {
        return this.customFieldGroups.filter((_, i) => i % 2 === 1)
      }
      return []
    }

  },
  methods: {
  }
}
</script>

<style lang="scss" scoped>
</style>
