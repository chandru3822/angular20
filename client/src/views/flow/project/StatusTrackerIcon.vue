<template>
  <v-btn fab height="28px"
         width="28px"
         v-on="on"
         :class="{'not-clickable': !clickable }"
         :style="{'background-color': '#F5F5F5'}"
         :outlined="currentStatusId !== milestone.id && milestone.btnColor === 'grey'"
         :color="currentStatusId  === milestone.id ? 'primary lighten-5' : milestone.btnColor"
         elevation="0">

    <v-icon size="16" :color="currentStatusId  === milestone.id ? 'white' : milestone.iconColor">{{milestone.iconTag || 'blank'}}</v-icon>
  </v-btn>
</template>

<script>

import {getRequest, getSnackbar, handleHidingGlobalLoader, logError} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import SpinnerInline from '@/components/SpinnerInline'
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'StatusTrackerIcon',
  components: {
    SpinnerInline
  },
  props: {
    currentStatusId: Number,
    milestone: Object,
    clickable: Boolean,
    on: Object
  },
  data() {
    return {
      constants,
    }
  },
  created() {
  },
  computed: {},
  methods: {

  }
}
</script>

<style lang="scss" scoped>

</style>

<style lang="scss">

</style>
